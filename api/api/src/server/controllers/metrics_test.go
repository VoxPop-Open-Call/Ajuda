package controllers

import (
	"testing"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/seeders"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type MetricsControllerTestSuite struct {
	suite.Suite
	metrics *MetricsController
	users   *UserController
	db      *gorm.DB
	acl     *access.ACL
}

// Run each test in a transaction.
func (s *MetricsControllerTestSuite) SetupTest() {
	tx := testDb.Begin()
	s.db = tx
	s.metrics = &MetricsController{tx, s.acl}
	s.users = &UserController{tx, s.acl, nil}
}

// Rollback the transaction after each test.
func (s *MetricsControllerTestSuite) TearDownTest() {
	s.db.Rollback()
}

func (s *MetricsControllerTestSuite) TestUserMetrics() {
	// Delete all current users and test using the ones created with
	// seeders.User.
	err := s.db.Exec("delete from users").Error
	s.Require().NoError(err)
	err = s.db.Exec("delete from task_types").Error
	s.Require().NoError(err)
	_, ctx, err := createRandomAdmin(s.users)
	s.Require().NoError(err)

	models.TaskType{}.Migrate(s.db)
	seeders.User.Seed(s.db)

	metrics, err := s.metrics.Users(ctx)
	s.NoError(err)
	s.NotEmpty(metrics)

	s.Equal(query.UserMetrics{
		TotalUsers:         8,
		TotalElders:        2,
		TotalVolunteers:    3,
		TotalVerifiedUsers: 5,
		AgeGroups: query.AgeGroups{
			AgeLt18:   2,
			Age18To25: 1,
			Age25To30: 1,
			Age30To40: 0,
			Age40To60: 1,
			Age60To75: 1,
			AgeGte75:  1,
		},
		GenderCount: query.GenderCount{
			M: 3,
			F: 2,
			X: 1,
		},
		LanguageCount: map[string]int64{
			"en":  3,
			"pt":  2,
			"fr":  2,
			"psr": 1,
		},
	}, metrics)
}

func (s *MetricsControllerTestSuite) TestTaskMetrics() {
	// Delete all current users and tasks and test using the ones created with
	// the seeders.
	err := s.db.Exec("delete from users").Error
	s.Require().NoError(err)
	err = s.db.Exec("delete from tasks").Error
	s.Require().NoError(err)
	err = s.db.Exec("delete from task_types").Error
	s.Require().NoError(err)

	models.TaskType{}.Migrate(s.db)
	seeders.User.Seed(s.db)
	seeders.Task.Seed(s.db)

	_, ctx, err := createRandomAdmin(s.users)
	s.Require().NoError(err)

	metrics, err := s.metrics.Tasks(ctx)
	s.NoError(err)
	s.NotEmpty(metrics)

	s.Equal(query.TaskMetrics{
		TotalTasks:          5,
		TotalPendingTasks:   1,
		TotalCompletedTasks: 2,
		TaskTypeCount: map[string]int64{
			"other":    3,
			"company":  1,
			"pharmacy": 1,
		},
		AveragePerDay:   0.24,
		AveragePerWeek:  1.67,
		AveragePerMonth: 5,
	}, metrics)
}

func TestMetricsController(t *testing.T) {
	acl := access.New()
	registerAllRules(&MetricsController{}, acl)
	suite.Run(t, &MetricsControllerTestSuite{
		acl: acl,
	})
}
