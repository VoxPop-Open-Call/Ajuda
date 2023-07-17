package controllers

import (
	"errors"
	"log"
	"regexp"

	"bitbucket.org/mobinteg/ajuda-mais/src/aws"
	"bitbucket.org/mobinteg/ajuda-mais/src/chat"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/jobs"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/middleware"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/gobutil"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/httputil"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/stringutil"
	"bitbucket.org/mobinteg/ajuda-mais/src/worker"
	"firebase.google.com/go/v4/messaging"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-playground/validator/v10"
	"github.com/go-redis/redis/v8"
	"gorm.io/gorm"
)

var orderByValidationRegex = regexp.MustCompile(
	`^(\w+, ?)*\w+ (asc|desc)$`,
)

// customValidations to register with gin's validation engine.
var customValidations = map[string]validator.Func{
	"order_by_clause": func(fl validator.FieldLevel) bool {
		return orderByValidationRegex.MatchString(fl.Field().String())
	},
}

type Store struct {
	Users           *UserController
	Password        *PasswordController
	Volunteers      *VolunteerController
	UserConditions  *UserConditionController
	Tasks           *TaskController
	TaskTypes       *TaskTypeController
	Assignments     *AssignmentController
	ExternalContent *ExternalContentController
	FCMTokens       *FCMTokenController
	Metrics         *MetricsController
	Languages       *LanguageController
	Chat            *ChatController
}

func NewStore(
	db *gorm.DB,
	acl *access.ACL,
	wrkr *worker.Worker,
	aws *aws.Client,
	chatClient *chat.Chat,
	rdb *redis.Client,
) *Store {
	// Register custom validation tags
	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		for k, f := range customValidations {
			v.RegisterValidation(k, f)
		}
	}

	users := &UserController{db, acl, aws.S3}
	registerAllRules(users, acl)

	password := &PasswordController{db, aws.SES}

	volunteers := &VolunteerController{db, acl}
	registerAllRules(volunteers, acl)

	userConditions := &UserConditionController{db}

	tasks := &TaskController{
		db, acl, wrkr,
		gobutil.NewGobCodec[messaging.Message](),
	}
	registerAllRules(tasks, acl)

	taskTypes := &TaskTypeController{db}

	assignments := &AssignmentController{
		db, acl, wrkr,
		gobutil.NewGobCodec[messaging.Message](),
	}
	registerAllRules(assignments, acl)

	external := &ExternalContentController{db, acl}
	registerAllRules(external, acl)

	fcm := &FCMTokenController{db}

	metrics := &MetricsController{db, acl}
	registerAllRules(metrics, acl)

	languages := &LanguageController{db}

	chat := &ChatController{
		db, chatClient, wrkr, rdb,
		gobutil.NewGobCodec[messaging.Message](),
	}

	return &Store{
		Users:           users,
		Password:        password,
		Volunteers:      volunteers,
		UserConditions:  userConditions,
		Tasks:           tasks,
		TaskTypes:       taskTypes,
		Assignments:     assignments,
		ExternalContent: external,
		FCMTokens:       fcm,
		Metrics:         metrics,
		Languages:       languages,
		Chat:            chat,
	}
}

// authorizer interface is used to control access to resources by authorized
// entities.
// Should return true iff ent has permission to perform action on res.
type authorizer interface {
	Authorize(ent any, action string, res any) bool
}

type rule struct {
	ent, res any
	action   string
	f        access.AuthFunc
}

func registerAllRules(r interface {
	Rules() []rule
}, acl *access.ACL) {
	for _, rule := range r.Rules() {
		acl.Register(rule.ent, rule.action, rule.res, rule.f)
	}
}

// scheduler interface contains the workers schedule method.
//
// This interface allows mocking the worker during testing.
type scheduler interface {
	Schedule(*worker.TaskConfig) error
}

type Pagination struct {
	// Limit is the maximum number of records to be returned.
	// The API doesn't enforce a limit, it's a responsibility of the client.
	Limit int `form:"limit"`

	// Offset is the number of records to skip when retrieving.
	Offset int `form:"offset"`
}

type orderBy string

// ToSnakeCase converts the orderBy string from camelCase (used by the API) to
// snake_case (which is employed by gorm for the column names).
func (o orderBy) ToSnakeCase() string {
	return stringutil.CamelToSnake(string(o))
}

type Sort struct {
	// OrderBy specifies the sorting order of the records returned by List
	// methods.
	OrderBy orderBy `form:"orderBy,default=id asc" binding:"omitempty,order_by_clause" example:"foo,bar asc" default:"id asc"`
}

// tokenClaims retrieves the token claims from the gin context.
func tokenClaims(ctx *gin.Context) (*middleware.Claims, error) {
	val, ok := ctx.Get(middleware.TokenClaimsKey)
	if !ok {
		return nil, errors.New("token claims not present in context")
	}

	claims, ok := val.(middleware.Claims)
	if !ok {
		return nil, errors.New("failed to assert type of token claims")
	}

	return &claims, nil
}

// tokenUser retrieves the user identified by the token claims in the context.
func tokenUser(ctx *gin.Context, db *gorm.DB) (models.User, error) {
	claims, err := tokenClaims(ctx)
	if err != nil {
		return models.User{}, err
	}

	user, err := query.Users.FromClaims(claims, db)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return user, httputil.NewErrorMsg(
			httputil.TokenUserNotFound,
			"the token is valid, but the subject doesn't exist",
		)
	}

	return user, err
}

func resourceNotFoundErr(name string) httputil.Error {
	return httputil.NewErrorMsg(
		httputil.RecordNotFound,
		name+" not found",
	)
}

func scheduleNotification(
	msg messaging.Message,
	targetID string,
	codec *gobutil.GobCodec[messaging.Message],
	db *gorm.DB,
	tasks scheduler,
) {
	if tokens, err := query.FCMTokens.Of(targetID, db); err != nil {
		log.Printf("failed to retrieve user tokens: %v", err)
	} else {
		for _, token := range tokens {
			msg.Token = token
			if data, err := codec.Encode(msg); err != nil {
				log.Printf("failed to encode message: %v", err)
			} else {
				if err = tasks.Schedule(&worker.TaskConfig{
					JobName: jobs.FcmNotify,
					Args:    data,
				}); err != nil {
					log.Printf("failed to schedule notification task: %v", err)
				}
			}
		}
	}
}
