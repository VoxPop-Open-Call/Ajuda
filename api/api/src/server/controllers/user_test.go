package controllers

import (
	"net/http/httptest"
	"sort"
	"strings"
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
	"github.com/stretchr/testify/suite"
	"gorm.io/gorm"
)

type UserControllerTestSuite struct {
	suite.Suite
	users *UserController
	db    *gorm.DB
	acl   *access.ACL
}

// Run each test in a transaction.
func (s *UserControllerTestSuite) SetupTest() {
	tx := testDb.Begin()
	s.db = tx
	s.users = &UserController{tx, s.acl, nil}
}

// Rollback the transaction after each test.
func (s *UserControllerTestSuite) TearDownTest() {
	s.db.Rollback()
}

func (s *UserControllerTestSuite) TestCreateUser() {
	// Create user WITHOUT `Subject`
	params := CreateUserParams{
		Name:  "Hugh Hughes",
		Email: "hugh_hughes@notanemail.org",
	}

	user, err := s.users.Create(params, nil)
	s.NoError(err)
	s.NotEmpty(user)

	s.Equal(params.Name, user.Name)
	s.Equal(params.Email, user.Email)

	s.NotZero(user.ID)
	s.NotZero(user.CreatedAt)
	s.NotZero(user.UpdatedAt)

	s.Equal(user.ID.String(), user.Subject)

	// Create user WITH `Subject`
	params = CreateUserParams{
		Email:   random.String(50),
		Subject: random.String(100),
	}

	user, err = s.users.Create(params, nil)
	s.NoError(err)
	s.NotEmpty(user)
	s.Equal(params.Email, user.Email)
	s.Equal(params.Subject, user.Subject)
}

func (s *UserControllerTestSuite) TestCreateUserDuplicatedEmail() {
	params := CreateUserParams{
		Name:  "some one",
		Email: "some_one@somewhere.com",
	}

	user, err := s.users.Create(params, nil)
	s.NotEmpty(user)
	s.NoError(err)

	user, err = s.users.Create(params, nil)
	s.Empty(user)
	s.EqualError(err,
		"ApiError{"+
			"code: Email Already Registered, "+
			"message: a user with the given email already exists"+
			"}",
	)
}

// Tests the validation of the CreateUserParams.
func (s *UserControllerTestSuite) TestCreateUserParams() {
	testcases := []struct {
		params CreateUserParams
		result string
	}{
		{
			params: CreateUserParams{
				Subject:  random.String(20),
				Password: random.String(20),
				Email:    random.String(20),
			},
			result: "Key: 'CreateUserParams.Subject' " +
				"Error:Field validation for 'Subject' failed on the 'excluded_with' tag\n" +
				"Key: 'CreateUserParams.Password' " +
				"Error:Field validation for 'Password' failed on the 'excluded_with' tag\n" +
				"Key: 'CreateUserParams.Email' Error:Field validation for 'Email' failed on the 'email' tag",
		},
		{
			params: CreateUserParams{},
			result: "Key: 'CreateUserParams.Subject' " +
				"Error:Field validation for 'Subject' failed on the 'required_without' tag\n" +
				"Key: 'CreateUserParams.Password' " +
				"Error:Field validation for 'Password' failed on the 'required_without' tag\n" +
				"Key: 'CreateUserParams.Email' " +
				"Error:Field validation for 'Email' failed on the 'required' tag",
		},
		{
			params: CreateUserParams{
				Password: random.String(20),
				Email:    random.String(10) + "@mobinteg.com",
				Name:     random.String(20),
			},
		},
		{
			params: CreateUserParams{
				Subject: random.String(20),
				Email:   random.String(10) + "@mobinteg.com",
				Name:    random.String(20),
			},
		},
	}

	validate := validator.New()
	validate.SetTagName("binding") // validator uses the `validate` tag by default
	for _, tc := range testcases {
		err := validate.Struct(tc.params)
		if tc.result == "" {
			s.NoError(err)
		} else {
			s.Equal(err.Error(), tc.result)
		}
	}
}

func (s *UserControllerTestSuite) TestProfileGenderValidation() {
	testcases := []struct {
		val string
		res string
	}{
		{val: "M"},
		{val: "F"},
		{val: "X"},
		{val: "m", res: "Key: 'Profile.Gender' " +
			"Error:Field validation for 'Gender' failed on the 'oneof' tag"},
		{val: "f", res: "Key: 'Profile.Gender' " +
			"Error:Field validation for 'Gender' failed on the 'oneof' tag"},
		{val: "1", res: "Key: 'Profile.Gender' " +
			"Error:Field validation for 'Gender' failed on the 'oneof' tag"},
		{val: " ", res: "Key: 'Profile.Gender' " +
			"Error:Field validation for 'Gender' failed on the 'oneof' tag"},
	}

	validate := validator.New()
	validate.SetTagName("binding") // validator uses the `validate` tag by default
	for _, tc := range testcases {
		err := validate.StructPartial(models.Profile{
			Gender: tc.val,
		}, "Gender")
		if tc.res == "" {
			s.NoError(err)
		} else {
			s.Equal(err.Error(), tc.res)

		}
	}

	err := validate.StructPartial(models.Profile{}, "Gender")
	s.NoError(err)
}

func (s *UserControllerTestSuite) TestGetUser() {
	user, ctx, err := createRandomUser(s.users)
	s.NotEmpty(user)
	s.NoError(err)

	result, err := s.users.Get(user.ID.String(), ctx)
	s.NotEmpty(result)
	s.NoError(err)

	// Ignore the `CreatedAt` and `UpdatedAt` fields
	result.CreatedAt = user.CreatedAt
	result.UpdatedAt = user.UpdatedAt

	user.Languages = []models.Language{}
	user.Conditions = []models.Condition{}

	s.Equal(user, result.User)
	s.NotNil(result.Location)
	s.Equal(&models.Location{}, result.Location)

	// ------------------------------------------------------ //
	// Location is not retrieved when queried by another user //
	// ------------------------------------------------------ //
	_, ctx2, err := createRandomUser(s.users)
	s.NoError(err)

	result, err = s.users.Get(user.ID.String(), ctx2)
	s.NotEmpty(result)
	s.NoError(err)
	s.Nil(result.Location)
}

func (s *UserControllerTestSuite) TestRating() {
	user, ctx, err := createRandomElder(s.users)
	s.NoError(err)

	volunteer, _, err := createRandomUser(s.users)
	s.NoError(err)

	err = s.db.Create(&models.Task{
		TaskType: models.TaskType{
			Code: random.String(5),
		},
		RequesterID: user.ID,
		Date:        "2023-04-04",
		Assignments: []models.Assignment{
			{User: volunteer, Rating: 5},
		},
	}).Error

	// ------------------------------ //
	// Returns the user's rating data //
	// ------------------------------ //
	rating, err := s.users.Rating(volunteer.ID.String(), ctx)
	s.NoError(err)
	s.NotEmpty(rating)

	s.Equal(5.0, rating.AverageRating)
	s.Equal(1, rating.ReviewCount)

	// ------------------------------------- //
	// Returns 404 if the user doesn't exist //
	// ------------------------------------- //
	uid, err := uuid.NewRandom()
	s.NoError(err)
	rating, err = s.users.Rating(uid.String(), ctx)
	s.Empty(rating)
	s.EqualError(err, "ApiError{"+
		"code: Record Not Found, "+
		"message: user not found"+
		"}")
}

func (s *UserControllerTestSuite) TestReviews() {
	user, ctx, err := createRandomElder(s.users)
	s.NoError(err)

	volunteer, _, err := createRandomUser(s.users)
	s.NoError(err)

	err = s.db.Create([]models.Task{
		{
			TaskType: models.TaskType{
				Code: random.String(5),
			},
			RequesterID: user.ID,
			Date:        "2023-04-04",
			Assignments: []models.Assignment{
				{User: volunteer, Rating: 5, Comment: "very good"},
			},
		},
		{
			TaskType: models.TaskType{
				Code: random.String(5),
			},
			RequesterID: user.ID,
			Date:        "2023-04-04",
			Assignments: []models.Assignment{
				{User: volunteer, Rating: 1, Comment: "very bad"},
			},
		},
		{
			TaskType: models.TaskType{
				Code: random.String(5),
			},
			RequesterID: user.ID,
			Date:        "2023-04-04",
			Assignments: []models.Assignment{
				// An assignment without a review should not be returned.
				{User: volunteer},
			},
		},
	}).Error

	// -------------------------- //
	// Returns the user's reviews //
	// -------------------------- //
	ctx.Request = httptest.NewRequest("GET",
		"/reviews?limit=5&offset=0&orderBy=id%20asc", nil)
	reviews, err := s.users.Reviews(volunteer.ID.String(), ctx)
	s.NoError(err)
	s.NotEmpty(reviews)
	s.Len(reviews, 2)

	// ------------------------------------- //
	// Returns 404 if the user doesn't exist //
	// ------------------------------------- //
	uid, err := uuid.NewRandom()
	s.NoError(err)
	reviews, err = s.users.Reviews(uid.String(), ctx)
	s.Empty(reviews)
	s.EqualError(err, "ApiError{"+
		"code: Record Not Found, "+
		"message: user not found"+
		"}")
}

func (s *UserControllerTestSuite) TestUpdateUser0() {
	user, ctx, err := createRandomUser(s.users)
	s.Require().NoError(err)
	s.Require().NotEmpty(ctx)
	s.Require().NotEmpty(user)

	taskType := models.TaskType{
		Code: random.String(30),
	}
	err = s.db.Create(&taskType).Error
	s.Require().NoError(err)
	s.Require().NotEmpty(taskType.ID)

	params := UpdateUserParams{
		Profile: models.Profile{
			Name:       "Ron Swanson",
			Gender:     "M",
			Languages:  []models.Language{},
			Conditions: []models.Condition{},
			Volunteer: &models.Volunteer{
				TaskTypes: []models.TaskType{taskType},
				Availabilities: []models.Availability{
					{
						WeekDay: time.Wednesday,
						Start:   "08:00Z",
						End:     "20:00Z",
					},
				},
			},
		},
		Email: "boss@parksandrec.gov",
	}

	result, err := s.users.Update(user.ID.String(), params, ctx)
	s.NotEmpty(result)
	s.NoError(err)

	s.Equal(user.ID, result.ID)
	s.Equal(params.Email, result.Email)

	s.Len(result.Profile.Volunteer.TaskTypes, 1)
	result.Profile.Volunteer.TaskTypes[0].CreatedAt =
		params.Volunteer.TaskTypes[0].CreatedAt
	result.Profile.Volunteer.TaskTypes[0].UpdatedAt =
		params.Volunteer.TaskTypes[0].UpdatedAt

	s.Equal(params.Profile, result.Profile)
	s.Equal(params.Volunteer, result.Volunteer)
	s.False(result.Verified)
	s.Empty(result.Elder)

	// ------------------------------------------------ //
	// Cannot define `Elder` after defining `Volunteer` //
	// ------------------------------------------------ //
	params = UpdateUserParams{
		Profile: models.Profile{
			Elder: &models.Elder{},
		},
	}

	result, err = s.users.Update(user.ID.String(), params, ctx)
	s.Empty(result)
	s.EqualError(err, "ApiError{"+
		"code: Bad Request, "+
		"message: cannot set 'elder' attributes on a 'volunteer' user"+
		"}")

	// ------------------------------------------ //
	// Cannot define both `Elder` and `Volunteer` //
	// ------------------------------------------ //
	params = UpdateUserParams{
		Profile: models.Profile{
			Elder: &models.Elder{},
			Volunteer: &models.Volunteer{
				TaskTypes: []models.TaskType{taskType},
				Availabilities: []models.Availability{
					{
						WeekDay: time.Wednesday,
						Start:   "08:00Z",
						End:     "20:00Z",
					},
				},
			},
		},
	}

	result, err = s.users.Update(user.ID.String(), params, ctx)
	s.Empty(result)
	s.EqualError(err, "ApiError{"+
		"code: Bad Request, "+
		"message: attributes 'elder' and 'volunteer' cannot be simultaneously defined"+
		"}")
}

func (s *UserControllerTestSuite) TestUpdateUser1() {
	user, ctx, err := createRandomUser(s.users)
	s.Require().NoError(err)
	s.Require().NotEmpty(ctx)
	s.Require().NotEmpty(user)

	params := UpdateUserParams{
		Profile: models.Profile{
			Name:     "Leslie Knope",
			Birthday: types.DatePtr("1975-01-18"),
			Gender:   "F",
			Languages: []models.Language{
				{Code: "en", Name: "English", NativeName: "English"},
			},
			Conditions: []models.Condition{
				{Code: "my-back-hurts-a-bit"},
			},
			FontScale: 1.0,
			Elder: &models.Elder{
				EmergencyContacts: []models.EmergencyContact{
					{
						Name:        "mom",
						PhoneNumber: "123456789",
					},
				},
			},
		},
		Email: "viceboss@parksandrec.gov",
	}

	result, err := s.users.Update(user.ID.String(), params, ctx)
	s.NotEmpty(result)
	s.NoError(err)

	s.Len(result.Profile.Elder.EmergencyContacts, 1)
	s.Equal(
		params.Profile.Elder.EmergencyContacts[0].Name,
		result.Profile.Elder.EmergencyContacts[0].Name,
	)
	s.Equal(
		params.Profile.Elder.EmergencyContacts[0].PhoneNumber,
		result.Profile.Elder.EmergencyContacts[0].PhoneNumber,
	)
	params.Profile.Elder.EmergencyContacts =
		result.Profile.Elder.EmergencyContacts

	s.Len(result.Conditions, 1)
	s.Equal(params.Conditions[0].Code, result.Conditions[0].Code)
	params.Conditions = result.Conditions

	s.Equal(user.ID, result.ID)
	s.Equal(params.Email, result.Email)
	s.Equal(params.Profile, result.Profile)
	s.Equal(params.Elder, result.Elder)
	s.Equal(params.Languages, result.Languages)
	s.True(result.Verified)
	s.Empty(params.Volunteer)

	// Test updating / replacing user languages, conditions and emergency contacts.
	params.Languages = []models.Language{
		{Code: "es", Name: "Spanish", NativeName: "español"},
		{Code: "pt", Name: "Portuguese", NativeName: "Português"},
	}
	params.Elder.EmergencyContacts = []models.EmergencyContact{
		{
			Name:        "granny",
			PhoneNumber: "987654321",
		},
	}
	params.Conditions = []models.Condition{
		{Code: "my-back-doesnt-hurt-anymore"},
	}

	result, err = s.users.Update(user.ID.String(), params, ctx)
	s.NotEmpty(result)
	s.NoError(err)

	sort.Slice(result.Languages, func(i, j int) bool {
		return result.Languages[i].Code < result.Languages[j].Code
	})

	s.Equal(params.Languages, result.Languages)

	s.Len(result.Elder.EmergencyContacts, 1)
	params.Elder.EmergencyContacts[0].BaseModel =
		result.Elder.EmergencyContacts[0].BaseModel
	s.Equal(params.Elder.EmergencyContacts, result.Elder.EmergencyContacts)

	s.Len(result.Conditions, 1)
	params.Conditions[0].BaseModel = result.Conditions[0].BaseModel
	s.Equal(params.Conditions, result.Conditions)

	var dbUser models.User
	err = s.db.Model(&models.User{}).
		Preload("Languages").
		Preload("Conditions").
		First(&dbUser, "users.id = ?", user.ID.String()).Error
	s.NoError(err)

	sort.Slice(dbUser.Languages, func(i, j int) bool {
		return dbUser.Languages[i].Code < dbUser.Languages[j].Code
	})
	s.Equal(params.Languages, dbUser.Languages)
	s.Equal(params.Conditions, dbUser.Conditions)
}

func (s *UserControllerTestSuite) TestUpdateUser2() {
	user, ctx, err := createRandomUser(s.users)
	s.Require().NoError(err)
	s.Require().NotEmpty(ctx)
	s.Require().NotEmpty(user)

	format := "2006-01-02"
	birthday, _ := time.Parse(format, "1969-07-20")

	taskTypes := []models.TaskType{
		{Code: random.String(30)},
		{Code: random.String(30)},
	}
	err = s.db.Create(&taskTypes).Error
	s.Require().NoError(err)
	s.Require().NotEmpty(taskTypes[0].ID)
	s.Require().NotEmpty(taskTypes[1].ID)

	var condition models.Condition
	err = s.db.First(&condition).Error
	s.Require().NoError(err)
	s.Require().NotEmpty(condition)

	params := UpdateUserParams{
		Profile: models.Profile{
			Name:     "Moon Landing",
			Birthday: types.DatePtr("1969-07-20"),
			Gender:   "X",
			Languages: []models.Language{
				{Code: "en", Name: "English", NativeName: "English"},
			},
			Conditions: []models.Condition{condition},
			FontScale:  1.0,
			Volunteer: &models.Volunteer{
				TaskTypes: []models.TaskType{taskTypes[0]},
				Availabilities: []models.Availability{
					{
						WeekDay: birthday.Weekday(),
						Start:   "20:17Z",
						End:     "23:00Z",
					},
				},
			},
		},
		Email: "moonlanding@nasa.gov",
	}

	result, err := s.users.Update(user.ID.String(), params, ctx)
	s.NotEmpty(result)
	s.NoError(err)

	s.Equal(user.ID, result.ID)
	s.Equal(params.Email, result.Email)

	s.Len(result.Profile.Volunteer.TaskTypes, 1)
	result.Profile.Volunteer.TaskTypes[0].CreatedAt =
		params.Volunteer.TaskTypes[0].CreatedAt
	result.Profile.Volunteer.TaskTypes[0].UpdatedAt =
		params.Volunteer.TaskTypes[0].UpdatedAt

	s.Equal(params.Profile, result.Profile)
	s.Equal(params.Volunteer, result.Volunteer)
	s.Equal(params.Languages, result.Languages)
	s.Empty(params.Elder)

	// Test updating / replacing volunteer availabilities and task types.
	params.Volunteer.Availabilities = []models.Availability{
		{
			WeekDay: time.Monday,
			Start:   "01:00+04:00",
			End:     "12:24+04:00",
		},
	}
	params.Volunteer.TaskTypes = []models.TaskType{
		taskTypes[1],
	}

	result, err = s.users.Update(user.ID.String(), params, ctx)
	s.NotEmpty(result)
	s.NoError(err)

	s.Equal(params.Volunteer.Availabilities, result.Volunteer.Availabilities)
	var dbVolunteer models.Volunteer
	err = s.db.Model(&models.Volunteer{}).
		Preload("Availabilities").
		Preload("TaskTypes").
		First(&dbVolunteer, "user_id = ?", user.ID.String()).Error
	s.NoError(err)
	s.Equal(params.Volunteer.Availabilities, dbVolunteer.Availabilities)

	s.Len(dbVolunteer.TaskTypes, 1)
	dbVolunteer.TaskTypes[0].CreatedAt = params.Volunteer.TaskTypes[0].CreatedAt
	dbVolunteer.TaskTypes[0].UpdatedAt = params.Volunteer.TaskTypes[0].UpdatedAt
	s.Equal(params.Volunteer.TaskTypes, dbVolunteer.TaskTypes)
}

func (s *UserControllerTestSuite) TestVerifyUser() {
	// ------------------------------------------ //
	// Verification should fail for regular users //
	// ------------------------------------------ //
	user, ctx, err := createRandomUser(s.users)
	s.NoError(err)
	s.NotEmpty(ctx)
	s.NotEmpty(user)

	res, err := s.users.Verify(user.ID.String(), ctx)
	s.Empty(res)
	s.EqualError(err, "ApiError{"+
		"code: Admin Access Required, "+
		"message: the user must be an administrator to perform this action"+
		"}")

	// -------------------------------------- //
	// Verification should succeed for admins //
	// -------------------------------------- //
	admin, ctx, err := createRandomAdmin(s.users)
	s.NoError(err)
	s.NotEmpty(ctx)
	s.NotEmpty(admin)

	res, err = s.users.Verify(user.ID.String(), ctx)
	s.NoError(err)

	s.Equal(user.ID, res.ID)
	s.True(res.Verified)

	var dbUser models.User
	err = s.db.Table("users").First(&dbUser, "id = ?", user.ID).Error
	s.NoError(err)
	s.Equal(user.ID, dbUser.ID)
	s.True(dbUser.Verified)
}

func (s *UserControllerTestSuite) TestListUsers() {
	for i := 0; i < 10; i++ {
		createRandomUser(s.users)
	}

	filters := ListUsersFilters{Pagination: Pagination{
		Limit:  5,
		Offset: 3,
	}}

	users, err := s.users.List(filters, nil)
	s.NoError(err)
	s.Len(users, 5)

	for _, user := range users {
		s.NotEmpty(user)
	}

	filters = ListUsersFilters{
		Pagination: Pagination{10, 0},
		Sort:       Sort{"lower(email) asc"},
	}
	users, err = s.users.List(filters, nil)
	s.NoError(err)
	s.Len(users, 10)

	prevEmail := users[0].Email
	for _, u := range users {
		s.GreaterOrEqual(strings.ToLower(u.Email), prevEmail)
		prevEmail = strings.ToLower(u.Email)
	}
}

func (s *UserControllerTestSuite) TestListUsersFilters() {
	for i := 0; i < 5; i++ {
		createRandomElder(s.users)
	}

	for i := 0; i < 5; i++ {
		createRandomVolunteer(s.users)
	}

	users, err := s.users.List(ListUsersFilters{
		Sort:   Sort{"createdAt"},
		Elders: true,
	}, nil)
	s.NotEmpty(users)
	s.NoError(err)

	for _, elder := range users {
		s.NotEmpty(elder)
		s.NotEmpty(elder.Elder)
		s.Nil(elder.Volunteer)
	}

	users, err = s.users.List(ListUsersFilters{
		Sort:       Sort{"createdAt"},
		Volunteers: true,
	}, nil)
	s.NotEmpty(users)
	s.NoError(err)

	for _, volunteer := range users {
		s.NotEmpty(volunteer)
		s.NotEmpty(volunteer.Volunteer)
		s.Nil(volunteer.Elder)
	}
}

func (s *UserControllerTestSuite) TestDeleteUser() {
	user, ctx, err := createRandomUser(s.users)
	s.NotEmpty(user)
	s.NoError(err)

	err = s.users.Delete(user.ID.String(), ctx)
	s.NoError(err)

	_, ctx2, err := createRandomUser(s.users)
	s.NoError(err)

	// Getting a user after deleting should return an error
	result, err := s.users.Get(user.ID.String(), ctx2)
	s.EqualError(err, "ApiError{"+
		"code: Record Not Found, "+
		"message: user not found"+
		"}")
	s.Empty(result)

	// Trying to delete the same user should return an error
	err = s.users.Delete(user.ID.String(), ctx)
	s.EqualError(err, "ApiError{"+
		"code: Token User Not Found, "+
		"message: the token is valid, but the subject doesn't exist"+
		"}")

	// ---------------------------- //
	// An admin can delete any user //
	// ---------------------------- //
	user, _, err = createRandomUser(s.users)
	s.NotEmpty(user)
	s.NoError(err)
	admin, ctx, err := createRandomAdmin(s.users)
	s.NotEmpty(admin)
	s.NoError(err)

	err = s.users.Delete(user.ID.String(), ctx)
	s.NoError(err)
}

func (s *UserControllerTestSuite) TestDeleteUserAssociations() {
	user, ctx, err := createRandomUser(s.users)
	s.NoError(err)
	s.NotEmpty(ctx)
	s.NotEmpty(user)

	params := UpdateUserParams{
		Email: random.String(50) + "@doh.gov",
		Profile: models.Profile{
			Name:  random.String(50),
			Elder: &models.Elder{},
		},
	}

	_, err = s.users.Update(user.ID.String(), params, ctx)
	s.NoError(err)

	var elder models.Elder
	err = s.db.Where("user_id = ?", user.ID).First(&elder).Error
	s.NoError(err)

	err = s.users.Delete(user.ID.String(), ctx)
	s.NoError(err)

	result, err := s.users.Get(user.ID.String(), ctx)
	s.Empty(result)
	s.EqualError(err, "ApiError{"+
		"code: Token User Not Found, "+
		"message: the token is valid, but the subject doesn't exist"+
		"}")

	err = s.db.Where("user_id = ?", user.ID).First(&elder).Error
	s.EqualError(err, gorm.ErrRecordNotFound.Error())
}

func TestUserController(t *testing.T) {
	acl := access.New()
	registerAllRules(&UserController{}, acl)
	suite.Run(t, &UserControllerTestSuite{
		acl: acl,
	})
}
