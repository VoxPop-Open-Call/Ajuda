package query

import (
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/config"
	"bitbucket.org/mobinteg/ajuda-mais/src/database"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/middleware"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type UserQueriesTestSuite struct {
	suite.Suite
	db *gorm.DB
	tx *gorm.DB
}

// Run each test in a transaction.
func (s *UserQueriesTestSuite) SetupTest() {
	s.tx = s.db.Begin()
}

// Rollback the transaction after each test.
func (s *UserQueriesTestSuite) TearDownTest() {
	s.tx.Rollback()
}

func (s *UserQueriesTestSuite) TestFromClaims() {
	uid, err := uuid.NewRandom()
	s.NoError(err)
	users := []models.User{
		{
			Email:   random.String(30),
			Subject: random.String(30),
		},
		{
			Email:     random.String(30),
			BaseModel: models.BaseModel{ID: uid},
			Subject:   uid.String(),
		},
	}
	err = s.tx.CreateInBatches(users, 5).Error
	s.NoError(err)

	user, err := Users.FromClaims(&middleware.Claims{
		Sub: users[0].Subject,
	}, s.tx)
	s.NoError(err)
	s.NotEmpty(user)
	s.Equal(users[0].Subject, user.Subject)

	user, err = Users.FromClaims(&middleware.Claims{
		Sub:  random.String(30),
		Name: users[1].ID.String(),
	}, s.tx)
	s.NoError(err)
	s.NotEmpty(user)
	s.Equal(users[1].Subject, user.Subject)
	s.Equal(users[1].ID, user.ID)

	user, err = Users.FromClaims(&middleware.Claims{
		Sub:  random.String(50),
		Name: random.String(50),
	}, s.tx)
	s.Empty(user)
	s.EqualError(err, "record not found")
}

func (s *UserQueriesTestSuite) TestRating() {
	user := models.User{
		Email:   random.String(40),
		Subject: random.String(50),
	}
	err := s.tx.Create(&user).Error
	s.NoError(err)

	volunteer1 := models.User{
		Email:   random.String(40),
		Subject: random.String(50),
	}
	err = s.tx.Create(&volunteer1).Error
	s.NoError(err)

	volunteer2 := models.User{
		Email:   random.String(40),
		Subject: random.String(50),
	}
	err = s.tx.Create(&volunteer2).Error
	s.NoError(err)

	err = s.tx.Create([]models.Task{
		{
			TaskType: models.TaskType{
				Code: random.String(5),
			},
			RequesterID: user.ID,
			Date:        "2023-04-04",
			Assignments: []models.Assignment{
				{User: volunteer1, Rating: 5},
				{User: volunteer2, Rating: 4},
			},
		},
		{

			TaskType:    models.TaskType{Code: random.String(5)},
			RequesterID: user.ID,
			Date:        "2023-04-04",
			Assignments: []models.Assignment{
				{User: volunteer1},
				{User: volunteer2, Rating: 3},
			},
		},
		{
			TaskType:    models.TaskType{Code: random.String(5)},
			RequesterID: user.ID,
			Date:        "2023-04-04",
			Assignments: []models.Assignment{
				{User: volunteer1, Rating: 4},
				{User: volunteer2},
			},
		},
	}).Error
	s.NoError(err)

	rating1, err := Users.Rating(volunteer1.ID.String(), s.tx)
	s.NoError(err)
	s.Equal(4.5, rating1.AverageRating)
	s.Equal(2, rating1.ReviewCount)

	rating2, err := Users.Rating(volunteer2.ID.String(), s.tx)
	s.NoError(err)
	s.Equal(3.5, rating2.AverageRating)
	s.Equal(2, rating2.ReviewCount)

	err = s.tx.Create(&models.Task{
		TaskType: models.TaskType{
			Code: random.String(5),
		},
		RequesterID: user.ID,
		Date:        "2023-04-04",
		Assignments: []models.Assignment{
			{User: volunteer2, Rating: 2},
		},
	}).Error
	s.NoError(err)

	rating1, err = Users.Rating(volunteer1.ID.String(), s.tx)
	s.NoError(err)
	s.Equal(4.5, rating1.AverageRating)
	s.Equal(2, rating1.ReviewCount)

	rating2, err = Users.Rating(volunteer2.ID.String(), s.tx)
	s.NoError(err)
	s.Equal(3.0, rating2.AverageRating)
	s.Equal(3, rating2.ReviewCount)
}

func (s *UserQueriesTestSuite) TestVolunteers() {
	users := []models.User{
		{
			Email:    random.String(20),
			Subject:  random.String(100),
			Verified: true,
			Profile: models.Profile{
				Languages: []models.Language{
					{Code: "en"}, {Code: "pt"},
				},
				Volunteer: &models.Volunteer{
					Availabilities: []models.Availability{
						{
							WeekDay: time.Monday,
							Start:   "08:00Z",
							End:     "20:00Z",
						},
					},
				},
			},
		},
		{
			Email:    "uniqueemailaddress@mobinteg.com",
			Subject:  random.String(100),
			Verified: true,
			Profile: models.Profile{
				Name: "John Doe",
				Languages: []models.Language{
					{Code: "de"}, {Code: "it"}, {Code: "fr"},
				},
				Volunteer: &models.Volunteer{
					Availabilities: []models.Availability{
						{
							WeekDay: time.Wednesday,
							Start:   "18:00Z",
							End:     "20:00Z",
						},
						{
							WeekDay: time.Thursday,
							Start:   "18:00Z",
							End:     "20:00Z",
						},
					},
				},
			},
		},
		{
			Email:   random.String(20),
			Subject: random.String(100),
			Profile: models.Profile{
				Volunteer: &models.Volunteer{
					Availabilities: []models.Availability{
						{
							WeekDay: time.Monday,
							Start:   "08:00Z",
							End:     "20:00Z",
						},
					},
				},
			},
		},
		{
			Email:   random.String(20),
			Subject: random.String(100),
			Profile: models.Profile{
				Elder: &models.Elder{},
			},
		},
		{
			Email:   random.String(20),
			Subject: random.String(100),
		},
	}
	err := s.tx.CreateInBatches(users, 5).Error
	s.NoError(err)

	var volunteers []models.User
	err = Users.Volunteers("", s.tx).Find(&volunteers).Error
	s.NoError(err)

	includes := func(users []models.User, email string) bool {
		for _, user := range users {
			if user.Email == email {
				return true
			}
		}
		return false
	}

	s.True(includes(volunteers, users[0].Email))
	s.True(includes(volunteers, users[1].Email))
	s.False(includes(volunteers, users[2].Email))
	s.False(includes(volunteers, users[3].Email))
	s.False(includes(volunteers, users[4].Email))

	s.GreaterOrEqual(len(volunteers), 2)
	for _, volunteer := range volunteers {
		s.NotEmpty(volunteer)
		s.NotEmpty(volunteer.Volunteer)
		s.NotEmpty(volunteer.Volunteer.Availabilities)
		s.NotEmpty(volunteer.Languages)
		s.Empty(volunteer.Elder)
		s.NotEmpty(volunteer.Email)
	}

	// ----------- //
	// Test search //
	// ----------- //
	var volunteers2 []models.User
	err = Users.Volunteers("UniqueEmailAddress", s.tx).Find(&volunteers2).Error
	s.NoError(err)
	s.Len(volunteers2, 1)
	s.Equal(users[1].Email, volunteers2[0].Email)

	var volunteers3 []models.User
	err = Users.Volunteers("john doe", s.tx).Find(&volunteers3).Error
	s.NoError(err)
	s.Len(volunteers3, 1)
	s.Equal(users[1].Email, volunteers3[0].Email)
}

func TestUserQueries(t *testing.T) {
	config, err := config.Load("../../../.env")
	require.NoError(t, err)

	db, err := database.Init(config.DbDsn())
	require.NoError(t, err)

	db.Logger = logger.Default.LogMode(logger.Silent)

	suite.Run(t, &UserQueriesTestSuite{db: db})
}
