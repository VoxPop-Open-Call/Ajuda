package controllers

import (
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
	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type AssignmentControllerTestSuite struct {
	suite.Suite
	users       *UserController
	tasks       *TaskController
	assignments *AssignmentController
	db          *gorm.DB
	acl         *access.ACL
	wrkr        *MockWorker
	codec       *gobutil.GobCodec[messaging.Message]
}

// Run each test in a transaction.
func (s *AssignmentControllerTestSuite) SetupTest() {
	tx := testDb.Begin()
	s.db = tx
	s.wrkr = &MockWorker{}
	s.assignments = &AssignmentController{tx, s.acl, s.wrkr, s.codec}
	s.tasks = &TaskController{tx, s.acl, nil, nil}
	s.users = &UserController{tx, s.acl, nil}
}

// Rollback the transaction after each test.
func (s *AssignmentControllerTestSuite) TearDownTest() {
	s.wrkr.AssertExpectations(s.T())
	s.db.Rollback()
}

func (s *AssignmentControllerTestSuite) TestCreateAssignment() {
	elder, elderCtx, err := createRandomElder(s.users)
	s.NoError(err)

	user, _, err := createRandomUser(s.users)
	s.NoError(err)
	token := random.AlphanumericString(30)
	s.Require().NoError(s.db.Create(&models.FCMToken{
		Token: token,
		User:  user,
	}).Error)

	task, err := createRandomTask(s.tasks, elderCtx)
	s.NoError(err)

	fakeUid, err := uuid.NewRandom()
	s.NoError(err)

	// -------------- //
	// Task not found //
	// -------------- //
	assignment, err := s.assignments.Create(CreateAssignmentParams{
		UserID: user.ID,
		TaskID: fakeUid,
	}, elderCtx)
	s.Empty(assignment)
	s.EqualError(err, "ApiError{code: Record Not Found, message: task not found}")

	// -------------- //
	// User not found //
	// -------------- //
	assignment, err = s.assignments.Create(CreateAssignmentParams{
		UserID: fakeUid,
		TaskID: task.ID,
	}, elderCtx)
	s.Empty(assignment)
	s.EqualError(err, "ApiError{code: Record Not Found, message: user not found}")

	// ------------------- //
	// Successfull request //
	// ------------------- //
	s.wrkr.On("Schedule", mock.MatchedBy(func(tc *worker.TaskConfig) bool {
		actual, err := s.codec.Decode(tc.Args)
		exp := firebase.NewAssignmentMessage(firebase.NewAssignmentMessageConfig{
			TaskID:        task.ID.String(),
			RequesterName: elder.Name,
		})
		exp.Token = token
		return err == nil && tc.JobName == jobs.FcmNotify && s.Equal(exp, actual)
	})).Return(nil)

	assignment, err = s.assignments.Create(CreateAssignmentParams{
		UserID: user.ID,
		TaskID: task.ID,
	}, elderCtx)
	s.NoError(err)
	s.NotEmpty(assignment)

	s.Equal(elder.ID, assignment.Task.RequesterID)
	s.Equal("pending", string(assignment.State))

	s.Equal(task.ID, assignment.TaskID)
	s.NotEmpty(assignment.Task)
	s.Equal(task.ID, assignment.Task.ID)

	s.Equal(user.ID, assignment.UserID)
	s.NotEmpty(assignment.User)
	s.Equal(user.ID, assignment.User.ID)
}

func (s *AssignmentControllerTestSuite) TestListAssignments() {
	user1, ctx1, err := createRandomElder(s.users)
	s.NoError(err)

	user2, ctx2, err := createRandomElder(s.users)
	s.NoError(err)

	task1, err := createRandomTask(s.tasks, ctx1)
	s.NoError(err)
	task2, err := createRandomTask(s.tasks, ctx2)
	s.NoError(err)

	assignment1, err := query.Assignments.Create(task1, user2, s.db)
	s.NoError(err)
	assignment2, err := query.Assignments.Create(task2, user1, s.db)

	assignments1, err := s.assignments.List(ListAssignmentFilters{
		Sort: Sort{OrderBy: "created_at asc"},
	}, ctx1)
	s.NoError(err)
	s.Len(assignments1, 1)
	s.Equal(assignment2.ID, assignments1[0].ID)
	s.Equal(assignment2.State, assignments1[0].State)
	s.Equal(assignment2.TaskID, assignments1[0].TaskID)
	s.Equal(assignment2.UserID, assignments1[0].UserID)

	assignments2, err := s.assignments.List(ListAssignmentFilters{
		Sort: Sort{OrderBy: "created_at asc"},
	}, ctx2)
	s.NoError(err)
	s.Len(assignments2, 1)
	s.Equal(assignment1.ID, assignments2[0].ID)
	s.Equal(assignment1.State, assignments2[0].State)
	s.Equal(assignment1.TaskID, assignments2[0].TaskID)
	s.Equal(assignment1.UserID, assignments2[0].UserID)
}

func (s *AssignmentControllerTestSuite) TestAcceptAssignment() {
	user, ctx, err := createRandomElder(s.users)
	s.NoError(err)
	task, err := createRandomTask(s.tasks, ctx)
	s.NoError(err)

	assignment, err := query.Assignments.Create(task, user, s.db)
	s.NoError(err)

	// --------------------------------------------- //
	// An unrelated user cannot accept an assignment //
	// --------------------------------------------- //
	_, ctx2, err := createRandomUser(s.users)
	s.NoError(err)

	res, err := s.assignments.Accept(assignment.ID.String(), ctx2)
	s.Empty(res)
	s.EqualError(err, "ApiError{"+
		"code: Forbidden Action, "+
		"message: the user does not have access to this operation"+
		"}")

	// ---------------------------------- //
	// The user can accept the assignment //
	// ---------------------------------- //
	res, err = s.assignments.Accept(assignment.ID.String(), ctx)
	s.NoError(err)

	s.Equal(assignment.ID, res.ID)
	s.Equal(assignment.UserID, res.UserID)
	s.Equal(assignment.TaskID, res.TaskID)
	s.Equal("accepted", string(res.State))

	var dbAssignment models.Assignment
	err = s.db.First(&dbAssignment, "id = ?", assignment.ID.String()).Error
	s.NoError(err)
	s.NotEmpty(dbAssignment)

	s.Equal(assignment.ID, dbAssignment.ID)
	s.Equal(assignment.UserID, dbAssignment.UserID)
	s.Equal(assignment.TaskID, dbAssignment.TaskID)
	s.Equal("accepted", string(dbAssignment.State))
}

func (s *AssignmentControllerTestSuite) TestRejectAssignment() {
	user, ctx, err := createRandomElder(s.users)
	s.NoError(err)
	task, err := createRandomTask(s.tasks, ctx)
	s.NoError(err)

	assignment, err := query.Assignments.Create(task, user, s.db)
	s.NoError(err)

	res, err := s.assignments.Reject(assignment.ID.String(), ctx)
	s.NoError(err)

	s.Equal(assignment.ID, res.ID)
	s.Equal(assignment.UserID, res.UserID)
	s.Equal(assignment.TaskID, res.TaskID)
	s.Equal("rejected", string(res.State))

	var dbAssignment models.Assignment
	err = s.db.First(&dbAssignment, "id = ?", assignment.ID.String()).Error
	s.NoError(err)
	s.NotEmpty(dbAssignment)

	s.Equal(assignment.ID, dbAssignment.ID)
	s.Equal(assignment.UserID, dbAssignment.UserID)
	s.Equal(assignment.TaskID, dbAssignment.TaskID)
	s.Equal("rejected", string(dbAssignment.State))
}

func (s *AssignmentControllerTestSuite) TestReviewAssignment() {
	elder, ctx, err := createRandomElder(s.users)
	s.NoError(err)

	task, err := createRandomTask(s.tasks, ctx)
	s.NoError(err)

	volunteer, ctx2, err := createRandomUser(s.users)
	s.NoError(err)
	token := random.AlphanumericString(30)
	s.Require().NoError(s.db.Create(&models.FCMToken{
		Token: token,
		User:  volunteer,
	}).Error)

	assignment, err := query.Assignments.Create(task, volunteer, s.db)
	s.NoError(err)

	// ------------------------------------- //
	// The user cannot review the assignment //
	// ------------------------------------- //
	_, err = s.assignments.Accept(assignment.ID.String(), ctx2)
	s.NoError(err)

	res, err := s.assignments.Review(
		assignment.ID.String(),
		ReviewAssignmentParams{
			Rating:  3,
			Comment: "umm, meh",
		},
		ctx2,
	)
	s.EqualError(err, "ApiError{"+
		"code: Forbidden Action, "+
		"message: the user does not have access to this operation"+
		"}")
	s.Empty(res)

	// ----------------------------------------------------------- //
	// The requester cannot review the assignment before it starts //
	// ----------------------------------------------------------- //
	_, err = s.tasks.Update(task.ID.String(), UpdateTaskParams{
		Date:     types.Date(time.Now().Add(10 * 24 * time.Hour).Format("2006-01-02")),
		TimeFrom: types.TimeTZPtr("15:00+02:00"),
		TimeTo:   types.TimeTZPtr("16:00+02:00"),
	}, ctx)
	s.NoError(err)

	res, err = s.assignments.Review(
		assignment.ID.String(),
		ReviewAssignmentParams{
			Rating:  3,
			Comment: "umm, meh",
		},
		ctx,
	)
	s.EqualError(err, "ApiError{"+
		"code: Forbidden Action, "+
		"message: an assignment cannot be reviewed before the task starts"+
		"}")
	s.Empty(res)

	// --------------------------------------- //
	// The requester can review the assignment //
	// --------------------------------------- //
	s.wrkr.On("Schedule", mock.MatchedBy(func(tc *worker.TaskConfig) bool {
		actual, err := s.codec.Decode(tc.Args)
		exp := firebase.ReviewNotification(firebase.ReviewNotificationConfig{
			TaskID:        task.ID.String(),
			AssignmentID:  assignment.ID.String(),
			RequesterID:   elder.ID.String(),
			RequesterName: elder.Name,
			Rating:        3,
			Comment:       "umm, meh",
		})
		exp.Token = token
		return err == nil && tc.JobName == jobs.FcmNotify && s.Equal(exp, actual)
	})).Return(nil)

	_, err = s.tasks.Update(task.ID.String(), UpdateTaskParams{
		Date:     types.Date(time.Now().Add(-2 * 24 * time.Hour).Format("2006-01-02")),
		TimeFrom: types.TimeTZPtr("15:00+02:00"),
		TimeTo:   types.TimeTZPtr("16:00+02:00"),
	}, ctx)
	s.NoError(err)

	res, err = s.assignments.Review(
		assignment.ID.String(),
		ReviewAssignmentParams{
			Rating:  3,
			Comment: "umm, meh",
		},
		ctx,
	)
	s.NoError(err)
	s.NotEmpty(res)
}

func TestAssignmentController(t *testing.T) {
	acl := access.New()
	registerAllRules(&UserController{}, acl)
	registerAllRules(&TaskController{}, acl)
	registerAllRules(&AssignmentController{}, acl)
	codec := gobutil.NewGobCodec[messaging.Message]()
	suite.Run(t, &AssignmentControllerTestSuite{
		acl:   acl,
		codec: codec,
	})
}
