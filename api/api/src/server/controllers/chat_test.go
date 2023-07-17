package controllers

import (
	"context"
	"net/http/httptest"
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/chat"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/firebase"
	"bitbucket.org/mobinteg/ajuda-mais/src/jobs"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/gobutil"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/stringutil"
	"bitbucket.org/mobinteg/ajuda-mais/src/worker"
	"firebase.google.com/go/v4/messaging"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

func TestRoomId(t *testing.T) {
	for i := 0; i < 10; i++ {
		id0 := uuid.New().String()
		id1 := uuid.New().String()
		assert.Equal(t, roomID(id0, id1), roomID(id1, id0), id0, id1)
	}
}

type ChatControllerTestSuite struct {
	suite.Suite
	chat       *ChatController
	users      *UserController
	tasks      *TaskController
	db         *gorm.DB
	chatClient *chat.Chat
	acl        *access.ACL
	wrkr       *MockWorker
	codec      *gobutil.GobCodec[messaging.Message]
}

// Run each test in a transaction.
func (s *ChatControllerTestSuite) SetupTest() {
	tx := testDb.Begin()
	s.db = tx
	s.chat = &ChatController{tx, s.chatClient, s.wrkr, testRDB, s.codec}
	s.tasks = &TaskController{tx, s.acl, nil, nil}
	s.users = &UserController{tx, s.acl, nil}
}

// Rollback the transaction after each test.
func (s *ChatControllerTestSuite) TearDownTest() {
	s.wrkr.AssertExpectations(s.T())
	s.db.Rollback()
}

func (s *ChatControllerTestSuite) TestGenerateToken() {
	user, ctx, err := createRandomUser(s.users)
	s.Require().NoError(err)

	ctx.Request = httptest.NewRequest(
		"GET", "/api/chat/token?withUser="+user.ID.String(), nil)
	token, err := s.chat.GenerateToken(ctx)
	s.Require().NoError(err)
	s.NotEmpty(token)

	_, client, err := s.chatClient.RedeemToken(context.Background(), token.Value)
	s.Require().NoError(err)
	s.Equal(client, user.ID.String())
}

func (s *ChatControllerTestSuite) TestPostMessages() {
	user, ctx, err := createRandomUser(s.users)
	s.Require().NoError(err)
	target, _, err := createRandomUser(s.users)
	s.Require().NoError(err)

	fcmToken := random.AlphanumericString(50)
	err = s.db.Create(&models.FCMToken{
		Token:  fcmToken,
		UserID: target.ID,
	}).Error
	s.Require().NoError(err)

	chat.PostRateLimit = 100
	chat.PostLimiterBurst = 100

	firstMsg := random.AlphanumericString(200)
	s.wrkr.On("Schedule", mock.MatchedBy(func(tc *worker.TaskConfig) bool {
		actual, err := s.codec.Decode(tc.Args)
		exp := firebase.ChatMsgMessage(firebase.ChatMsgMessageConfig{
			FromID:   user.ID.String(),
			FromName: user.Name,
			Msg:      stringutil.Ellipsis(firstMsg, 100),
		})
		exp.Token = fcmToken
		return err == nil && tc.JobName == jobs.FcmNotify && s.Equal(exp, actual)
	})).Return(nil)

	msgs := make([]string, 25)
	for i := 0; i < 25; i++ {
		text := firstMsg
		if i != 0 {
			text = random.AlphanumericString(200)
		}
		msg, err := s.chat.PostMessage(PostMessageParams{
			Text:   text,
			ToUser: target.ID.String(),
		}, ctx)
		s.Require().NoError(err)
		msgs[i] = msg.Text
		time.Sleep(5 * time.Millisecond)
	}

	res, err := s.chat.ListMessages(ListMessageFilters{
		Pagination: Pagination{
			Limit:  25,
			Offset: 0,
		},
		WithUser: target.ID.String(),
	}, ctx)
	s.Require().NoError(err)
	s.Len(res, 25)
	for i, msg := range res {
		s.Equal(msgs[24-i], msg.Text)
	}
}

func TestChatController(t *testing.T) {
	acl := access.New()
	registerAllRules(&UserController{}, acl)
	registerAllRules(&TaskController{}, acl)
	codec := gobutil.NewGobCodec[messaging.Message]()
	chatClient := chat.New(testRDB)
	suite.Run(t, &ChatControllerTestSuite{
		acl:        acl,
		wrkr:       &MockWorker{},
		chatClient: chatClient,
		codec:      codec,
	})
}
