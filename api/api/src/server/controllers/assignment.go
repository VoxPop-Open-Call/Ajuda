package controllers

import (
	"errors"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/firebase"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/gobutil"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/httputil"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/stringutil"
	"firebase.google.com/go/v4/messaging"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type AssignmentController struct {
	db       *gorm.DB
	acl      authorizer
	tasks    scheduler
	msgCodec *gobutil.GobCodec[messaging.Message]
}

// Rules returns the acl for the assignment controller.
func (AssignmentController) Rules() []rule {
	return []rule{
		{models.User{}, models.Assignment{}, "change-state", func(ent, res any) bool {
			user := ent.(models.User)
			assignment := res.(models.Assignment)
			return user.ID == assignment.UserID && assignment.State == "pending"
		}},
		{models.User{}, models.Assignment{}, "create", func(ent, res any) bool {
			user := ent.(models.User)
			assignment := res.(models.Assignment)
			return user.ID == assignment.Task.RequesterID
		}},
		{models.User{}, models.Assignment{}, "review", func(ent, res any) bool {
			user := ent.(models.User)
			assignment := res.(models.Assignment)
			return user.ID == assignment.Task.RequesterID &&
				assignment.State == "accepted"
		}},
	}
}

type ListAssignmentFilters struct {
	Pagination
	Sort

	State     string `form:"state" binding:"omitempty,oneof=pending accepted rejected" example:"pending"`
	Upcoming  bool   `form:"upcoming"`  // Only retrieve upcoming assignments
	Completed bool   `form:"completed"` // Only retrieve completed assignments
}

// List all assignments for the logged in user.
//
//	@Summary		List all assignments for the logged in user
//	@Description	The assignment includes the task it pertains to and its requester.
//	@Tags			assignments
//	@Produce		json
//	@Security		OIDCToken
//	@Security		AuthHeader
//	@Param			filters			query		ListAssignmentFilters	false	"Filters"
//	@Success		200				{array}		models.Assignment
//	@Failure		400,401,404,500	{object}	middleware.ApiError
//	@Router			/assignments  [get]
func (c *AssignmentController) List(
	filters ListAssignmentFilters,
	ctx *gin.Context,
) ([]models.Assignment, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return nil, err
	}

	tx := query.Assignments.ForUser(user.ID.String(), c.db)

	if filters.Completed {
		tx = query.Assignments.Completed(tx)
	}
	if filters.Upcoming {
		tx = query.Assignments.Upcoming(tx)
	}

	var assignments []models.Assignment
	err = tx.
		Limit(filters.Limit).
		Offset(filters.Offset).
		Where(&models.Assignment{
			State: models.AssignmentState(filters.State),
		}).
		Order(filters.OrderBy.ToSnakeCase()).
		Find(&assignments).Error

	return assignments, err
}

func (c *AssignmentController) scheduleAssignmentNotification(
	userID string,
	task models.Task,
) {
	scheduleNotification(firebase.NewAssignmentMessage(
		firebase.NewAssignmentMessageConfig{
			TaskID:        task.ID.String(),
			RequesterName: task.Requester.Name,
		},
	), userID, c.msgCodec, c.db, c.tasks)
}

type CreateAssignmentParams struct {
	UserID uuid.UUID `json:"userId" binding:"required"`
	TaskID uuid.UUID `json:"taskId" binding:"required"`
}

// Create a assignment.
//
//	@Summary		Create a new assignment and return it
//	@Description	A user can only create an assignment for tasks of which they are the requester.
//	@Description	The assignment is created in the `pending` state.
//	@Tags			assignments
//	@Produce		json
//	@Security		OIDCToken
//	@Security		AuthHeader
//	@Param			params			body		CreateAssignmentParams	true	"Params"
//	@Success		201				{object}	models.Assignment
//	@Failure		400,401,403,500	{object}	middleware.ApiError
//	@Router			/assignments [post]
func (c *AssignmentController) Create(
	params CreateAssignmentParams,
	ctx *gin.Context,
) (models.Assignment, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return models.Assignment{}, err
	}

	var task models.Task
	if err = c.db.Model(&models.Task{}).
		Joins("Requester").
		First(&task, "tasks.id", params.TaskID).Error; err != nil {
		return models.Assignment{}, resourceNotFoundErr("task")
	}

	var volunteer models.User
	if err = c.db.Model(&models.User{}).
		First(&volunteer, "id", params.UserID).Error; err != nil {
		return models.Assignment{}, resourceNotFoundErr("user")
	}

	assignment := models.Assignment{
		Task: &task,
		User: volunteer,
	}

	if ok := c.acl.Authorize(user, "create", assignment); !ok {
		return models.Assignment{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	res, err := query.Assignments.Create(
		*assignment.Task,
		assignment.User,
		c.db,
	)
	if err != nil {
		return models.Assignment{}, err
	}

	c.scheduleAssignmentNotification(res.UserID.String(), task)

	return res, nil
}

func (c *AssignmentController) setAssignmentState(
	id string,
	state models.AssignmentState,
	ctx *gin.Context,
) (models.Assignment, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return models.Assignment{}, err
	}

	var assignment models.Assignment
	err = c.db.First(&assignment, "id = ?", id).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return models.Assignment{}, resourceNotFoundErr("assignment")
	}

	if ok := c.acl.Authorize(
		user, "change-state", assignment,
	); !ok {
		return models.Assignment{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	assignment.State = state
	err = c.db.Save(assignment).Error

	return assignment, err
}

// Accept a assignment to perform a task.
//
//	@Summary	Accept a assignment to perform a task
//	@Tags		assignments
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id					path		string	true	"Assignment Id"	Format(UUID)
//	@Success	200					{object}	models.Assignment
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/assignments/{id}/accept [put]
func (c *AssignmentController) Accept(
	id string,
	ctx *gin.Context,
) (models.Assignment, error) {
	return c.setAssignmentState(id, "accepted", ctx)
}

// Reject a assignment to perform a task.
//
//	@Summary	Reject a assignment to perform a task
//	@Tags		assignments
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id					path		string	true	"Assignment Id"	Format(UUID)
//	@Success	200					{object}	models.Assignment
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/assignments/{id}/reject [put]
func (c *AssignmentController) Reject(
	id string,
	ctx *gin.Context,
) (models.Assignment, error) {
	return c.setAssignmentState(id, "rejected", ctx)
}

type ReviewAssignmentParams struct {
	Rating  int    `json:"rating" binding:"required,gte=1,lte=5"`
	Comment string `json:"comment"`
}

func (c *AssignmentController) scheduleReviewNotification(
	targetID string,
	assignment models.Assignment,
) {
	scheduleNotification(firebase.ReviewNotification(
		firebase.ReviewNotificationConfig{
			TaskID:        assignment.Task.ID.String(),
			AssignmentID:  assignment.ID.String(),
			RequesterID:   assignment.Task.RequesterID.String(),
			RequesterName: assignment.Task.Requester.Name,
			Rating:        assignment.Rating,
			Comment:       stringutil.Ellipsis(assignment.Comment, 50),
		},
	), targetID, c.msgCodec, c.db, c.tasks)
}

// Review an assignment.
//
//	@Summary		Review an assignment by Id and return it
//	@Description	A user can only review an assignment for tasks of which they are the requester.
//	@Description	Also, an assignment can only be reviewed if it is in the `accepted` state, and
//	@Description	after the scheduled date and time.
//	@Tags			assignments
//	@Produce		json
//	@Security		OIDCToken
//	@Security		AuthHeader
//	@Param			id					path		string					true	"Assignment Id"	Format(UUID)
//	@Param			params				body		ReviewAssignmentParams	true	"Params"
//	@Success		200					{object}	models.Assignment
//	@Failure		400,401,403,404,500	{object}	middleware.ApiError
//	@Router			/assignments/{id}/review [put]
func (c *AssignmentController) Review(
	id string,
	params ReviewAssignmentParams,
	ctx *gin.Context,
) (models.Assignment, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return models.Assignment{}, err
	}

	var assignment models.Assignment
	if err = c.db.
		Joins("Task").
		Preload("Task.Requester").
		First(&assignment, "assignments.id = ?", id).
		Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return models.Assignment{}, resourceNotFoundErr("assignment")
		}
		return models.Assignment{}, err
	}

	if ok := c.acl.Authorize(
		user, "review", assignment,
	); !ok {
		return models.Assignment{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	startTime, err := assignment.Task.StartTime()
	if err != nil {
		return models.Assignment{}, httputil.NewError(
			httputil.InternalServerError,
			err,
		)
	}

	if startTime.After(time.Now()) {
		return models.Assignment{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			"an assignment cannot be reviewed before the task starts",
		)
	}

	assignment.Rating = params.Rating
	assignment.Comment = params.Comment
	err = c.db.Omit(clause.Associations).Save(assignment).Error

	c.scheduleReviewNotification(assignment.UserID.String(), assignment)

	return assignment, err
}
