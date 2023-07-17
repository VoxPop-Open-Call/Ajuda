package controllers

import (
	"sort"
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/firebase"
	"bitbucket.org/mobinteg/ajuda-mais/src/jobs"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/gobutil"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"bitbucket.org/mobinteg/ajuda-mais/src/worker"
	"firebase.google.com/go/v4/messaging"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type TaskControllerTestSuite struct {
	suite.Suite
	tasks *TaskController
	users *UserController
	db    *gorm.DB
	acl   *access.ACL
	wrkr  *MockWorker
	codec *gobutil.GobCodec[messaging.Message]
}

// Run each test in a transaction.
func (s *TaskControllerTestSuite) SetupTest() {
	tx := testDb.Begin()
	s.db = tx
	s.tasks = &TaskController{tx, s.acl, s.wrkr, s.codec}
	s.users = &UserController{tx, s.acl, nil}
}

// Rollback the transaction after each test.
func (s *TaskControllerTestSuite) TearDownTest() {
	s.db.Rollback()
}

func (s *TaskControllerTestSuite) TestCreateTask() {
	user, ctx, err := createRandomElder(s.users)
	s.NoError(err)
	s.NotEmpty(ctx)
	s.NotEmpty(user)

	params := CreateTaskParams{
		TaskTypeCode: "custom",
		Description:  random.String(50),
		Date:         "2024-10-05",
	}

	task, err := s.tasks.Create(params, ctx)
	s.NoError(err)
	s.NotEmpty(task)

	s.Equal(params.TaskTypeCode, task.TaskType.Code)
	s.Equal(params.Description, task.Description)
	s.Equal(params.Date, task.Date)
	s.Equal(user.ID, task.RequesterID)
	s.Equal(user.Email, task.Requester.Email)
}

func (s *TaskControllerTestSuite) TestUpdateTask() {
	user, ctx, err := createRandomElder(s.users)
	s.NoError(err)
	s.NotEmpty(ctx)
	s.NotEmpty(user)

	params := CreateTaskParams{
		TaskTypeCode: "walkin-park",
		Description:  random.String(50),
		Date:         "2023-07-15",
		TimeFrom:     types.TimeTZPtr("08:30Z"),
		TimeTo:       types.TimeTZPtr("12:00Z"),
	}

	task, err := s.tasks.Create(params, ctx)
	s.NoError(err)
	s.NotEmpty(task)

	updateParams := UpdateTaskParams{
		TaskTypeCode: random.String(10),
		Description:  random.String(50),
		Date:         "2023-08-16",
		TimeFrom:     types.TimeTZPtr("09:30Z"),
		TimeTo:       types.TimeTZPtr("13:00Z"),
	}

	task, err = s.tasks.Update(task.ID.String(), updateParams, ctx)

	s.Equal(updateParams.TaskTypeCode, task.TaskType.Code)
	s.Equal(updateParams.Description, task.Description)
	s.Equal(updateParams.Date, task.Date)
	s.Equal(updateParams.TimeFrom, task.TimeFrom)
	s.Equal(updateParams.TimeTo, task.TimeTo)
	s.Equal(user.ID, task.RequesterID)
	s.Equal(user.Email, task.Requester.Email)
}

func (s *TaskControllerTestSuite) TestGetTask() {
	user, ctx, err := createRandomElder(s.users)
	s.NoError(err)
	s.NotEmpty(ctx)
	s.NotEmpty(user)

	params := CreateTaskParams{
		TaskTypeCode: "custom",
		Description:  random.String(50),
		Date:         "2024-10-05",
	}
	exp, err := s.tasks.Create(params, ctx)
	s.NotEmpty(exp)
	s.NoError(err)

	task, err := s.tasks.Get(exp.ID.String(), ctx)
	s.NotEmpty(task)
	s.NoError(err)

	exp.Assignments = []models.Assignment{}

	s.WithinDuration(exp.CreatedAt, task.CreatedAt, time.Millisecond)
	exp.CreatedAt = task.CreatedAt
	s.WithinDuration(exp.UpdatedAt, task.UpdatedAt, time.Millisecond)
	exp.UpdatedAt = task.UpdatedAt

	s.WithinDuration(exp.TaskType.CreatedAt, task.TaskType.CreatedAt, time.Millisecond)
	exp.TaskType.CreatedAt = task.TaskType.CreatedAt
	s.WithinDuration(exp.TaskType.UpdatedAt, task.TaskType.UpdatedAt, time.Millisecond)
	exp.TaskType.UpdatedAt = task.TaskType.UpdatedAt

	s.Equal(user.ID, task.RequesterID)
	s.Equal(exp.RequesterID, task.RequesterID)
	exp.Requester = task.Requester

	s.Equal(exp, task)
}

// Get Task method returns the assignments for the task.
func (s *TaskControllerTestSuite) TestGetTaskAssignments() {
	_, ctx, err := createRandomElder(s.users)
	s.NoError(err)

	params := CreateTaskParams{
		TaskTypeCode: "custom",
		Description:  random.String(50),
		Date:         "2023-01-01",
	}

	exp, err := s.tasks.Create(params, ctx)
	s.NoError(err)

	var users = [3]models.User{}
	for i := range users {
		user, _, err := createRandomUser(s.users)
		s.NoError(err)
		users[i] = user
	}

	err = s.db.Create(&models.Assignment{
		Task:  &exp,
		User:  users[0],
		State: "accepted",
	}).Error
	s.NoError(err)

	err = s.db.Create(&models.Assignment{
		Task:  &exp,
		User:  users[1],
		State: "pending",
	}).Error
	s.NoError(err)

	err = s.db.Create(&models.Assignment{
		Task:  &exp,
		User:  users[2],
		State: "rejected",
	}).Error
	s.NoError(err)

	task, err := s.tasks.Get(exp.ID.String(), ctx)
	s.NotEmpty(task)
	s.NoError(err)

	sort.Slice(task.Assignments, func(i, j int) bool {
		return task.Assignments[i].State < task.Assignments[j].State
	})

	s.Len(task.Assignments, 3)
	s.Equal("accepted", string(task.Assignments[0].State))
	s.Equal("pending", string(task.Assignments[1].State))
	s.Equal("rejected", string(task.Assignments[2].State))

	s.NotEmpty(task.Assignments[0].User)
	s.NotEmpty(task.Assignments[1].User)
	s.NotEmpty(task.Assignments[2].User)

	s.Equal(users[0].ID, task.Assignments[0].UserID)
	s.Equal(users[1].ID, task.Assignments[1].UserID)
	s.Equal(users[2].ID, task.Assignments[2].UserID)
}

// Test List only retrieves tasks created by the logged in user.
func (s *TaskControllerTestSuite) TestListTasks() {
	err := s.db.Exec("delete from tasks").Error
	s.Require().NoError(err)

	user1, ctx1, err := createRandomElder(s.users)
	s.NoError(err)
	s.NotEmpty(ctx1)
	s.NotEmpty(user1)

	user2, ctx2, err := createRandomElder(s.users)
	s.NoError(err)
	s.NotEmpty(ctx2)
	s.NotEmpty(user2)

	// user1's tasks
	task1, err := createRandomTask(s.tasks, ctx1)
	s.NoError(err)
	task2, err := createRandomTask(s.tasks, ctx1)
	s.NoError(err)

	// user2's tasks
	task3, err := createRandomTask(s.tasks, ctx2)
	s.NoError(err)
	task4, err := createRandomTask(s.tasks, ctx2)
	s.NoError(err)

	tasks1, err := s.tasks.List(ListTaskFilters{
		Sort: Sort{"createdAt asc"},
	}, ctx1)
	s.NoError(err)

	s.Equal(task1.ID, tasks1[0].ID)
	s.Equal(task1.Requester.ID, tasks1[0].Requester.ID)
	s.Equal(user1.ID, tasks1[0].Requester.ID)
	s.Equal(task2.ID, tasks1[1].ID)
	s.Equal(task2.Requester.ID, tasks1[1].Requester.ID)
	s.Equal(user1.ID, tasks1[1].Requester.ID)

	tasks2, err := s.tasks.List(ListTaskFilters{
		Sort: Sort{"createdAt asc"},
	}, ctx2)
	s.NoError(err)

	s.Equal(task3.ID, tasks2[0].ID)
	s.Equal(task3.Requester.ID, tasks2[0].Requester.ID)
	s.Equal(user2.ID, tasks2[0].Requester.ID)
	s.Equal(task4.ID, tasks2[1].ID)
	s.Equal(task4.Requester.ID, tasks2[1].Requester.ID)
	s.Equal(user2.ID, tasks2[1].Requester.ID)

	// ----------------------------- //
	// Admin users receive all tasks //
	// ----------------------------- //
	_, ctx, err := createRandomAdmin(s.users)
	s.NoError(err)
	tasks, err := s.tasks.List(ListTaskFilters{
		Sort: Sort{"createdAt asc"},
	}, ctx)

	s.Len(tasks, 4)

	s.Equal(task1.ID, tasks[0].ID)
	s.Equal(task1.Requester.ID, tasks[0].Requester.ID)
	s.Equal(user1.ID, tasks[0].Requester.ID)
	s.Equal(task2.ID, tasks[1].ID)
	s.Equal(task2.Requester.ID, tasks[1].Requester.ID)
	s.Equal(user1.ID, tasks[1].Requester.ID)

	s.Equal(task3.ID, tasks[2].ID)
	s.Equal(task3.Requester.ID, tasks[2].Requester.ID)
	s.Equal(user2.ID, tasks[2].Requester.ID)
	s.Equal(task4.ID, tasks[3].ID)
	s.Equal(task4.Requester.ID, tasks[3].Requester.ID)
	s.Equal(user2.ID, tasks[3].Requester.ID)
}

func (s *TaskControllerTestSuite) TestListTaskFilters() {
	elder, ctx, err := createRandomElder(s.users)
	s.Require().NoError(err)
	s.Require().NotEmpty(ctx)
	s.Require().NotEmpty(elder)

	now := time.Now()

	// ---------------------- //
	// Create completed tasks //
	// ---------------------- //
	completedTasks := []CreateTaskParams{
		{
			TaskTypeCode: random.String(10),
			Description:  random.String(50),
			Date:         types.Date(now.AddDate(-1, -2, 0).Format(types.DateFormat)),
			TimeFrom:     types.TimeTZPtr("12:00Z"),
			TimeTo:       types.TimeTZPtr("13:30Z"),
		},
		{
			TaskTypeCode: random.String(10),
			Description:  random.String(50),
			Date:         types.Date(now.AddDate(0, 0, -1).Format(types.DateFormat)),
			TimeFrom:     types.TimeTZPtr("12:00Z"),
			TimeTo:       types.TimeTZPtr("13:30Z"),
		},
		{
			TaskTypeCode: random.String(10),
			Description:  random.String(50),
			Date:         types.Date(now.Format(types.DateFormat)),
			TimeFrom:     types.TimeTZPtr(now.Add(-2 * time.Minute).Format(types.TimeTZFormat)),
			TimeTo:       types.TimeTZPtr(now.Add(-time.Minute).Format(types.TimeTZFormat)),
		},
	}

	for _, task := range completedTasks {
		_, err := s.tasks.Create(task, ctx)
		s.Require().NoError(err)
	}

	res, err := s.tasks.List(ListTaskFilters{
		Sort:      Sort{"date asc"},
		Completed: true,
	}, ctx)
	s.Require().NoError(err)

	s.Len(res, 3)
	s.Equal(completedTasks[0].Description, res[0].Description)
	s.Equal(completedTasks[1].Description, res[1].Description)
	s.Equal(completedTasks[2].Description, res[2].Description)

	res, err = s.tasks.List(ListTaskFilters{
		Sort:     Sort{"date asc"},
		Upcoming: true,
	}, ctx)
	s.Require().NoError(err)
	s.Len(res, 0)

	// --------------------- //
	// Create upcoming tasks //
	// --------------------- //
	upcomingTasks := []CreateTaskParams{
		{
			TaskTypeCode: random.String(10),
			Description:  random.String(50),
			Date:         types.Date(now.Format(types.DateFormat)),
		},
		{
			TaskTypeCode: random.String(10),
			Description:  random.String(50),
			Date:         types.Date(now.Format(types.DateFormat)),
			TimeFrom:     types.TimeTZPtr(now.Add(time.Minute).Format(types.TimeTZFormat)),
			TimeTo:       types.TimeTZPtr(now.Add(2 * time.Minute).Format(types.TimeTZFormat)),
		},
		{
			TaskTypeCode: random.String(10),
			Description:  random.String(50),
			Date:         types.Date(now.AddDate(0, 0, 1).Format(types.DateFormat)),
			TimeFrom:     types.TimeTZPtr("12:00Z"),
			TimeTo:       types.TimeTZPtr("13:30Z"),
		},
		{
			TaskTypeCode: random.String(10),
			Description:  random.String(50),
			Date:         types.Date(now.AddDate(1, 2, 0).Format(types.DateFormat)),
			TimeFrom:     types.TimeTZPtr("12:00Z"),
			TimeTo:       types.TimeTZPtr("13:30Z"),
		},
	}

	for _, task := range upcomingTasks {
		_, err := s.tasks.Create(task, ctx)
		s.Require().NoError(err)
	}

	res, err = s.tasks.List(ListTaskFilters{
		Sort:      Sort{"date asc"},
		Completed: true,
	}, ctx)
	s.Require().NoError(err)

	s.Len(res, 3)
	s.Equal(completedTasks[0].Description, res[0].Description)
	s.Equal(completedTasks[1].Description, res[1].Description)
	s.Equal(completedTasks[2].Description, res[2].Description)

	res, err = s.tasks.List(ListTaskFilters{
		Sort:     Sort{"date asc"},
		Upcoming: true,
	}, ctx)
	s.Require().NoError(err)

	s.Len(res, 4)
	s.Equal(upcomingTasks[0].Description, res[0].Description)
	s.Equal(upcomingTasks[1].Description, res[1].Description)
	s.Equal(upcomingTasks[2].Description, res[2].Description)
	s.Equal(upcomingTasks[3].Description, res[3].Description)
}

func (s *TaskControllerTestSuite) TestAbleToCancel() {
	elder, _, err := createRandomElder(s.users)
	s.Require().NoError(err)

	volunteer1, _, err := createRandomVolunteer(s.users)
	s.Require().NoError(err)

	volunteer2, _, err := createRandomVolunteer(s.users)
	s.Require().NoError(err)

	task := &models.Task{
		Date:      types.Date(time.Now().Add(3 * 24 * time.Hour).Format(types.DateFormat)),
		Requester: elder,
		TaskType: models.TaskType{
			Code: random.String(30),
		},
		Assignments: []models.Assignment{
			{
				BaseModel: models.BaseModel{
					CreatedAt: time.Now().Add(-2 * time.Hour),
				},
				State: "rejected",
				User:  volunteer1,
			},
			{
				BaseModel: models.BaseModel{
					CreatedAt: time.Now().Add(-1 * time.Hour),
				},
				State: "accepted",
				User:  volunteer2,
			},
		},
	}
	err = s.db.Create(task).Error
	s.Require().NoError(err)

	assignment, err := query.Tasks.LatestAssignment(task.ID.String(), s.db)
	s.Require().NoError(err)
	s.Require().Equal(volunteer2.ID, assignment.UserID)
	s.Require().Equal(volunteer2.ID, assignment.User.ID)

	s.True(ableToCancel(task, nil))
	s.True(ableToCancel(task, assignment))

	task.Date = types.Date(time.Now().Format(types.DateFormat))
	s.False(ableToCancel(task, assignment))

	assignment.State = "pending"
	s.True(ableToCancel(task, assignment))
	assignment.State = "rejected"
	s.True(ableToCancel(task, assignment))
	s.True(ableToCancel(task, nil))
}

func (s *TaskControllerTestSuite) TestCancel() {
	elder, elderCtx, err := createRandomElder(s.users)
	s.Require().NoError(err)
	volunteer1, _, err := createRandomVolunteer(s.users)
	s.Require().NoError(err)
	volunteer2, volunteerCtx, err := createRandomVolunteer(s.users)
	s.Require().NoError(err)

	token := random.AlphanumericString(30)
	s.Require().NoError(s.db.Create(&models.FCMToken{
		Token: token,
		User:  volunteer2,
	}).Error)

	task := models.Task{
		Date:      types.Date(time.Now().Add(3 * 24 * time.Hour).Format(types.DateFormat)),
		Requester: elder,
		TaskType: models.TaskType{
			Code: random.String(30),
		},
		Assignments: []models.Assignment{
			{
				BaseModel: models.BaseModel{
					CreatedAt: time.Now().Add(-2 * time.Hour),
				},
				State: "rejected",
				User:  volunteer1,
			},
			{
				BaseModel: models.BaseModel{
					CreatedAt: time.Now().Add(-1 * time.Hour),
				},
				State: "accepted",
				User:  volunteer2,
			},
		},
	}
	err = s.db.Create(&task).Error
	s.Require().NoError(err)

	s.wrkr.On("Schedule", mock.MatchedBy(func(tc *worker.TaskConfig) bool {
		actual, err := s.codec.Decode(tc.Args)
		exp := firebase.TaskCanceledMessage(firebase.TaskCanceledMessageConfig{
			TaskID:        task.ID.String(),
			RequesterName: elder.Name,
		})
		exp.Token = token
		return err == nil && tc.JobName == jobs.FcmNotify && s.Equal(exp, actual)
	})).Return(nil)

	_, err = s.tasks.Cancel(task.ID.String(), volunteerCtx)
	s.EqualError(err, "ApiError{code: Record Not Found, message: task not found}")

	res, err := s.tasks.Cancel(task.ID.String(), elderCtx)
	s.NoError(err)
	s.True(res.Canceled)

	s.wrkr.AssertExpectations(s.T())
}

func TestTaskController(t *testing.T) {
	acl := access.New()
	registerAllRules(&UserController{}, acl)
	registerAllRules(&TaskController{}, acl)
	codec := gobutil.NewGobCodec[messaging.Message]()
	suite.Run(t, &TaskControllerTestSuite{
		acl:   acl,
		wrkr:  &MockWorker{},
		codec: codec,
	})
}
