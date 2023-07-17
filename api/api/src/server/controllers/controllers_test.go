package controllers

import (
	"log"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/config"
	"bitbucket.org/mobinteg/ajuda-mais/src/database"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/middleware"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"bitbucket.org/mobinteg/ajuda-mais/src/worker"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-playground/validator/v10"
	"github.com/go-redis/redis/v8"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var testDb *gorm.DB
var testRDB *redis.Client

type MockWorker struct {
	mock.Mock
}

func (w *MockWorker) Schedule(t *worker.TaskConfig) error {
	return w.Called(t).Error(0)
}

// createRandomUser creates a new user, returns it, and also returns a gin test
// context with the token claims set to the new user.
func createRandomUser(users *UserController) (models.User, *gin.Context, error) {
	params := CreateUserParams{
		Name:     random.String(5),
		Email:    random.String(100) + "@test.org",
		Password: "pass@word",
	}

	user, err := users.Create(params, nil)

	ctx, _ := gin.CreateTestContext(httptest.NewRecorder())
	ctx.Set(middleware.TokenClaimsKey, middleware.Claims{
		Sub: user.ID.String(),
	})

	return user, ctx, err
}

// createRandomElder is like createRandomUser, except the created user has an
// elder profile.
func createRandomElder(users *UserController) (models.User, *gin.Context, error) {
	user, ctx, err := createRandomUser(users)

	elder := &models.Elder{
		UserID: user.ID,
	}

	upsertUserProfile(elder, users.db)
	user.Elder = elder

	return user, ctx, err
}

// createRandomVolunteer is like createRandomUser, except the created user has a
// volunteer profile.
func createRandomVolunteer(users *UserController) (models.User, *gin.Context, error) {
	user, ctx, err := createRandomUser(users)

	volunteer := &models.Volunteer{
		UserID: user.ID,
		Availabilities: []models.Availability{
			{
				WeekDay: time.Monday,
				Start:   "09:00Z",
				End:     "17:00Z",
			},
		},
	}

	upsertUserProfile(volunteer, users.db)
	user.Volunteer = volunteer

	return user, ctx, err
}

// createRandomAdmin is like createRandomUser, except the created user has
// admin privileges.
func createRandomAdmin(users *UserController) (models.User, *gin.Context, error) {
	user := models.User{
		Email:    random.String(100) + "@test.org",
		Admin:    true,
		Verified: true,
		Profile: models.Profile{
			Name: random.String(50),
		},
	}
	err := users.db.Create(&user).Error

	ctx, _ := gin.CreateTestContext(httptest.NewRecorder())
	ctx.Set(middleware.TokenClaimsKey, middleware.Claims{
		Sub: user.ID.String(),
	})

	return user, ctx, err
}

func createRandomTask(tasks *TaskController, ctx *gin.Context) (models.Task, error) {
	params := CreateTaskParams{
		TaskTypeCode: random.String(10),
		Description:  random.String(50),
		Date:         "2023-04-01",
		TimeFrom:     types.TimeTZPtr("12:00Z"),
		TimeTo:       types.TimeTZPtr("13:30Z"),
	}

	return tasks.Create(params, ctx)
}

func TestOrderBy(t *testing.T) {
	for i, tc := range []struct {
		val, exp string
	}{
		{"id asc", "id asc"},
		{"id,name asc", "id,name asc"},
		{"id, name asc", "id, name asc"},
		{"createdAt", "created_at"},
		{"createdAt, updatedAt, email asc", "created_at, updated_at, email asc"},
		{"articleURL", "article_url"},
		{"FCMToken", "fcm_token"},
	} {
		assert.Equal(t, tc.exp, orderBy(tc.val).ToSnakeCase(),
			"failed on test %d: %s", i, tc.val)
	}
}

func TestOrderByValidationRegex(t *testing.T) {
	for i, tc := range []struct {
		val string
		exp bool
	}{
		{"id asc", true},
		{"id, name asc", true},
		{"id, createdAt desc", true},
		{"id, name, data123 desc", true},
		{"id,name asc", true},
		{"id,name desc", true},
		{"id,name desc;drop table users", false},
		{"id, name desc, (select 1)", false},
		{"id, name, email, desc", false},
	} {
		assert.Equal(t, tc.exp,
			orderByValidationRegex.MatchString(tc.val),
			"failed on test case %d", i)
	}
}

// Connect to the database to test the controllers.
// Each controller test suite should run inside a transaction, to prevent side effects.
func TestMain(m *testing.M) {
	config, err := config.Load("../../../.env")
	if err != nil {
		log.Fatalf("error loading config: %v", err)
	}
	gin.SetMode(gin.TestMode)

	// Register custom validation tags
	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		for k, f := range customValidations {
			v.RegisterValidation(k, f)
		}
	}

	testDb, err = database.Init(config.DbDsn())
	if err != nil {
		log.Fatalf("error connecting to the database: %v", err)
	}

	testDb.Logger = logger.Default.LogMode(logger.Silent)

	testRDB = redis.NewClient(&redis.Options{Addr: config.RedisAddr()})

	os.Exit(m.Run())
}
