package controllers

import (
	"errors"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/firebase"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/gobutil"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/httputil"
	"firebase.google.com/go/v4/messaging"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

const (
	// Amount of time before a task is due where the requester is no longer able
	// to cancel it.
	TaskCancelationDeadline = 24 * time.Hour
)

type TaskController struct {
	db       *gorm.DB
	acl      authorizer
	tasks    scheduler
	msgCodec *gobutil.GobCodec[messaging.Message]
}

// Rules returns the acl for the task controller.
func (TaskController) Rules() []rule {
	return []rule{
		{models.User{}, models.Task{}, "get,update,cancel", func(ent, res any) bool {
			user := ent.(models.User)
			task := res.(models.Task)
			return user.ID == task.RequesterID
		}},
		{models.User{}, models.Task{}, "create", func(ent, _ any) bool {
			user := ent.(models.User)
			return user.Elder != nil
		}},
	}
}

type ListTaskFilters struct {
	Pagination
	Sort
	Upcoming  bool `form:"upcoming"`  // Only retrieve upcoming tasks
	Completed bool `form:"completed"` // Only retrieve completed tasks
}

// List all tasks created by the logged in user.
//
//	@Summary		List all tasks created by the logged in user
//	@Description	Also returns the list of assignments for this task.
//	@Description	Admin users will receive tasks from all users.
//	@Tags			tasks
//	@Produce		json
//	@Security		OIDCToken
//	@Security		AuthHeader
//	@Param			filters		query		ListTaskFilters	false	"Filters"
//	@Success		200			{array}		models.Task
//	@Failure		400,401,500	{object}	middleware.ApiError
//	@Router			/tasks  [get]
func (c *TaskController) List(
	filters ListTaskFilters,
	ctx *gin.Context,
) ([]models.Task, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return nil, err
	}

	var tx *gorm.DB
	if user.Admin {
		tx = query.Tasks.All(c.db)
	} else {
		tx = query.Tasks.RequestedBy(user.ID.String(), c.db)
	}

	if filters.Completed {
		tx = query.Tasks.Completed(tx)
	}
	if filters.Upcoming {
		tx = query.Tasks.Upcoming(tx)
	}

	var tasks []models.Task
	err = tx.
		Limit(filters.Limit).
		Offset(filters.Offset).
		Order(filters.OrderBy.ToSnakeCase()).
		Find(&tasks).Error

	return tasks, err
}

// Retrieve a task.
//
//	@Summary		Retrieve a task by Id
//	@Description	Only returns tasks requested by the logged in user.
//	@Description	Also returns the list of assignments for this task.
//	@Tags			tasks
//	@Produce		json
//	@Security		OIDCToken
//	@Security		AuthHeader
//	@Param			id					path		string	true	"Task Id"	Format(UUID)
//	@Success		200					{object}	models.Task
//	@Failure		400,401,403,404,500	{object}	middleware.ApiError
//	@Router			/tasks/{id} [get]
func (c *TaskController) Get(id string, ctx *gin.Context) (models.Task, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return models.Task{}, err
	}

	var task models.Task
	err = query.Tasks.
		RequestedBy(user.ID.String(), c.db).
		First(&task, "tasks.id = ?", id).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return models.Task{}, resourceNotFoundErr("task")
	}
	if err != nil {
		return models.Task{}, err
	}

	if ok := c.acl.Authorize(user, "get", task); !ok {
		return models.Task{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	return task, nil
}

type CreateTaskParams struct {
	TaskTypeCode string        `json:"taskTypeCode" binding:"required" example:"pharmacy"`
	Description  string        `json:"description"`
	Date         types.Date    `form:"date" binding:"required,datetime=2006-01-02" example:"2023-03-30"`
	TimeFrom     *types.TimeTZ `form:"timeFrom" binding:"omitempty,datetime=15:04Z07:00" example:"12:00+02:00"`
	TimeTo       *types.TimeTZ `form:"timeTo" binding:"omitempty,datetime=15:04Z07:00" example:"13:30+02:00"`
}

// Create a task.
//
//	@Summary	Create a new task and return it
//	@Tags		tasks
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		params			body		CreateTaskParams	true	"Params"
//	@Success	201				{object}	models.Task
//	@Failure	400,401,403,500	{object}	middleware.ApiError
//	@Router		/tasks [post]
func (c *TaskController) Create(
	params CreateTaskParams,
	ctx *gin.Context,
) (models.Task, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return models.Task{}, err
	}

	taskType := models.TaskType{
		Code: params.TaskTypeCode,
	}

	if err = c.db.Where("code = ?", params.TaskTypeCode).
		FirstOrCreate(&taskType).Error; err != nil {
		return models.Task{}, err
	}

	task := models.Task{
		Requester:   user,
		Description: params.Description,
		Date:        params.Date,
		TimeFrom:    params.TimeFrom,
		TimeTo:      params.TimeTo,
		TaskType:    taskType,
	}

	if ok := c.acl.Authorize(user, "create", task); !ok {
		return models.Task{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	err = c.db.Create(&task).Error

	return task, err
}

type UpdateTaskParams struct {
	TaskTypeCode string        `json:"taskTypeCode" binding:"required" example:"pharmacy"`
	Description  string        `json:"description"`
	Date         types.Date    `form:"date" binding:"omitempty,datetime=2006-01-02" example:"2023-03-30"`
	TimeFrom     *types.TimeTZ `form:"timeFrom" binding:"omitempty,datetime=15:04Z07:00" example:"12:00+02:00"`
	TimeTo       *types.TimeTZ `form:"timeTo" binding:"omitempty,datetime=15:04Z07:00" example:"13:30+02:00"`
}

// Update a task.
//
//	@Summary	Update a task by Id and return it
//	@Tags		tasks
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id					path		string				true	"Task Id"	Format(UUID)
//	@Param		params				body		UpdateTaskParams	true	"Params"
//	@Success	200					{object}	models.Task
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/tasks/{id} [put]
func (c *TaskController) Update(
	id string,
	params UpdateTaskParams,
	ctx *gin.Context,
) (models.Task, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return models.Task{}, err
	}

	var task models.Task
	err = query.Tasks.
		RequestedBy(user.ID.String(), c.db).
		First(&task, "tasks.id = ?", id).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return models.Task{}, resourceNotFoundErr("task")
	}
	if err != nil {
		return models.Task{}, err
	}

	if ok := c.acl.Authorize(user, "update", task); !ok {
		return models.Task{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	taskType := models.TaskType{
		Code: params.TaskTypeCode,
	}

	if err = c.db.Where("code = ?", params.TaskTypeCode).
		FirstOrCreate(&taskType).Error; err != nil {
		return models.Task{}, err
	}

	task.TaskType = taskType
	task.Description = params.Description
	task.Date = params.Date
	task.TimeFrom = params.TimeFrom
	task.TimeTo = params.TimeTo

	err = c.db.Save(&task).Error
	return task, err
}

func ableToCancel(task *models.Task, assignment *models.Assignment) (bool, error) {
	if assignment == nil || assignment.State != "accepted" {
		return true, nil
	}

	start, err := task.StartTime()
	if err != nil {
		return false, err
	}

	deadline := start.Add(-TaskCancelationDeadline)

	return time.Now().Before(deadline), nil
}

// scheduleCancelationNotification schedules a task to notify the given user
// that the task was canceled.
func (c *TaskController) scheduleCancelationNotification(
	targetID string,
	task models.Task,
) {
	scheduleNotification(firebase.TaskCanceledMessage(
		firebase.TaskCanceledMessageConfig{
			TaskID:        task.ID.String(),
			RequesterName: task.Requester.Name,
		},
	), targetID, c.msgCodec, c.db, c.tasks)
}

// Cancel a task.
//
//	@Summary	Cancel a task
//	@Tags		tasks
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id					path		string	true	"Task Id"	Format(UUID)
//	@Success	200					{object}	models.Task
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/tasks/{id}/cancel [put]
func (c *TaskController) Cancel(id string, ctx *gin.Context) (models.Task, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return models.Task{}, err
	}

	task := new(models.Task)
	assignment := new(models.Assignment)
	if err = c.db.Transaction(func(tx *gorm.DB) error {
		err = query.Tasks.
			RequestedBy(user.ID.String(), tx).
			First(task, "tasks.id = ?", id).Error

		if errors.Is(err, gorm.ErrRecordNotFound) {
			return resourceNotFoundErr("task")
		}
		if err != nil {
			return err
		}

		if ok := c.acl.Authorize(user, "cancel", *task); !ok {
			return httputil.NewErrorMsg(
				httputil.Forbidden,
				httputil.ForbiddenMessage,
			)
		}

		assignment, err = query.Tasks.LatestAssignment(task.ID.String(), tx)
		if err != nil {
			return err
		}

		if ok, reason := ableToCancel(task, assignment); !ok {
			return httputil.NewError(httputil.UnableToCancelTask, reason)
		}

		task.Canceled = true

		return tx.Save(task).Error
	}); err != nil {
		return models.Task{}, err
	}

	if assignment != nil {
		c.scheduleCancelationNotification(assignment.User.ID.String(), *task)
	}

	return c.Get(id, ctx)
}
