package controllers

import (
	"errors"
	"fmt"
	"regexp"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/httputil"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/password"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type UserController struct {
	db        *gorm.DB
	acl       authorizer
	presigner interface {
		PresignGetProfilePicture(userId string) (string, string, error)
		PresignPutProfilePicture(userId string) (string, string, error)
		PresignDeleteProfilePicture(userId string) (string, string, error)
	}
}

// Rules returns the acl for the user controller.
func (UserController) Rules() []rule {
	return []rule{
		{models.User{}, models.User{},
			"update,update-picture,delete-picture",
			func(ent, res any) bool {
				user := ent.(models.User)
				params := res.(models.User)
				return user.ID == params.ID
			}},
		{models.User{}, models.User{}, "delete", func(ent, res any) bool {
			user := ent.(models.User)
			params := res.(models.User)
			return user.ID == params.ID || user.Admin
		}},
		{models.User{}, models.User{}, "verify", func(ent, _ any) bool {
			return ent.(models.User).Admin
		}},
	}
}

var duplicateEmailRegex = regexp.MustCompile(
	"duplicate key value violates unique constraint \"users_email_key\"",
)

type ListUsersFilters struct {
	Pagination
	Sort
	// Only return volunteer users.
	Volunteers bool `form:"volunteers,default=false" default:"false"`
	// Only return elder users.
	Elders bool `form:"elders,default=false" default:"false"`
}

// Lists all users.
//
//	@Summary	List all users
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		filters		query		ListUsersFilters	false	"Filters"
//	@Success	200			{array}		models.User
//	@Failure	400,401,500	{object}	middleware.ApiError
//	@Router		/users  [get]
func (c *UserController) List(
	filters ListUsersFilters,
	_ *gin.Context,
) ([]models.User, error) {
	tx := c.db.Model(&models.User{})
	if filters.Volunteers {
		tx = tx.Joins("INNER JOIN volunteers ON users.id = volunteers.user_id")
	}
	if filters.Elders {
		tx = tx.Joins("INNER JOIN elders ON users.id = elders.user_id")
	}

	var users []models.User
	err := query.Users.
		WithAssociations(tx).
		Limit(filters.Limit).
		Offset(filters.Offset).
		Order(filters.OrderBy.ToSnakeCase()).
		Find(&users).Error

	return users, err
}

type UserResponse struct {
	models.User

	// Location is only retrieved if the requested user is:
	// - the same as the one identified by the bearer token in the request;
	// - a volunteer, in which case the address field is redacted;
	Location *models.Location `json:"location,omitempty"`
}

// Get retrieves a user.
//
//	@Summary	Retrieve a user by Id
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id				path		string	true	"User Id"	Format(UUID)
//	@Success	200				{object}	UserResponse
//	@Failure	400,401,404,500	{object}	middleware.ApiError
//	@Router		/users/{id} [get]
func (c *UserController) Get(id string, ctx *gin.Context) (UserResponse, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return UserResponse{}, err
	}

	var dbUser models.User
	err = query.Users.
		WithAssociations(c.db).
		First(&dbUser, "users.id = ?", id).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return UserResponse{}, resourceNotFoundErr("user")
	}

	res := UserResponse{
		User: dbUser,
	}

	if user.ID == dbUser.ID {
		res.Location = &dbUser.Location
	} else if dbUser.Volunteer != nil {
		res.Location = &dbUser.Location
		res.Location.Address = ""
	}

	return res, err
}

// Get retrieves the logged-in user.
//
//	@Summary	Retrieve the currently logged-in user
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Success	200				{object}	UserResponse
//	@Failure	400,401,404,500	{object}	middleware.ApiError
//	@Router		/users/current [get]
func (c *UserController) GetCurrent(ctx *gin.Context) (UserResponse, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return UserResponse{}, err
	}

	return c.Get(user.ID.String(), ctx)
}

type PresignedResponse struct {
	URL    string `json:"url"`
	Method string `json:"method"`
}

// GetPictureURL generates a pre-signed url to retrieve the user's profile picture.
//
//	@Summary	Generate a pre-signed url to retrieve the user's profile picture
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id				path		string	true	"User Id"	Format(UUID)
//	@Success	200				{object}	PresignedResponse
//	@Failure	400,401,404,500	{object}	middleware.ApiError
//	@Router		/users/{id}/picture-get-url [get]
func (c UserController) GetPictureURL(
	id string,
	_ *gin.Context,
) (PresignedResponse, error) {
	url, method, err := c.presigner.PresignGetProfilePicture(id)
	return PresignedResponse{url, method}, err
}

// PutPictureURL generates a pre-signed url to update the user's profile picture.
//
//	@Summary	Generate a pre-signed url to update the user's profile picture
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id					path		string	true	"User Id"	Format(UUID)
//	@Success	200					{object}	PresignedResponse
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/users/{id}/picture-put-url [get]
func (c UserController) PutPictureURL(
	id string,
	ctx *gin.Context,
) (PresignedResponse, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return PresignedResponse{}, err
	}

	userId, err := uuid.Parse(id)
	if err != nil {
		return PresignedResponse{},
			httputil.NewError(httputil.BadRequest, err)
	}

	if ok := c.acl.Authorize(
		user, "update-picture", models.User{
			BaseModel: models.BaseModel{ID: userId},
		},
	); !ok {
		return PresignedResponse{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	url, method, err := c.presigner.PresignPutProfilePicture(id)
	return PresignedResponse{url, method}, err
}

// DeletePictureURL generates a pre-signed url to delete the user's profile
// picture.
//
//	@Summary	Generate a pre-signed url to delete the user's profile picture
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id					path		string	true	"User Id"	Format(UUID)
//	@Success	200					{object}	PresignedResponse
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/users/{id}/picture-delete-url [get]
func (c UserController) DeletePictureURL(
	id string,
	ctx *gin.Context,
) (PresignedResponse, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return PresignedResponse{}, err
	}

	userId, err := uuid.Parse(id)
	if err != nil {
		return PresignedResponse{},
			httputil.NewError(httputil.BadRequest, err)
	}

	if ok := c.acl.Authorize(
		user, "delete-picture", models.User{
			BaseModel: models.BaseModel{ID: userId},
		},
	); !ok {
		return PresignedResponse{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}
	url, method, err := c.presigner.PresignDeleteProfilePicture(id)
	return PresignedResponse{url, method}, err
}

// Rating retrieves a user's rating.
//
//	@Summary	Retrieve a user's rating
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id				path		string	true	"User Id"	Format(UUID)
//	@Success	200				{object}	query.RatingData
//	@Failure	400,401,404,500	{object}	middleware.ApiError
//	@Router		/users/{id}/rating [get]
func (c UserController) Rating(id string, _ *gin.Context) (query.RatingData, error) {
	if err := c.db.
		First(&models.User{}, "users.id = ?", id).
		Error; errors.Is(err, gorm.ErrRecordNotFound) {
		return query.RatingData{}, resourceNotFoundErr("user")
	}

	return query.Users.Rating(id, c.db)
}

type ListReviewFilters struct {
	Pagination
	Sort
}

type UserReview struct {
	ID      uuid.UUID   `json:"id"`
	Rating  int         `json:"rating"`
	Comment string      `json:"comment"`
	TaskID  uuid.UUID   `json:"taskId"`
	Task    models.Task `json:"task"`
}

// Reviews lists the reviews for a user.
//
//	@Summary	List the reviews for a user
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id				path		string				true	"User Id"	Format(UUID)
//	@Param		params			query		ListReviewFilters	false	"Filters"
//	@Success	200				{array}		UserReview
//	@Failure	400,401,404,500	{object}	middleware.ApiError
//	@Router		/users/{id}/reviews [get]
func (c UserController) Reviews(
	id string,
	ctx *gin.Context,
) ([]UserReview, error) {
	if err := c.db.
		First(&models.User{}, "users.id = ?", id).
		Error; errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, resourceNotFoundErr("user")
	}

	var filters ListReviewFilters
	if err := ctx.ShouldBindQuery(&filters); err != nil {
		return nil, httputil.NewError(httputil.BadRequest, err)
	}

	var reviews []UserReview
	result := query.Users.
		Reviews(id, c.db).
		Limit(filters.Limit).
		Offset(filters.Offset).
		Order(filters.OrderBy.ToSnakeCase()).
		Find(&reviews)

	return reviews, result.Error
}

type CreateUserParams struct {
	// Subject is the `sub` field from the ID token claims.
	// Required when registering with a third party provider.
	// Subject and Password are mutually exclusive.
	Subject string `json:"subject" binding:"required_without=Password,excluded_with=Password"`

	// Password is required when the Subject is not provided, i.e. when
	// registering using email and password.
	// Subject and Password are mutually exclusive.
	Password string `json:"password" binding:"required_without=Subject,excluded_with=Subject,omitempty,min=8"`

	Email string `json:"email" binding:"required,email"`
	Name  string `json:"name"`
}

// Creates a user.
//
//	@Summary	Create a new user and return it
//	@Tags		users
//	@Produce	json
//	@Param		params		body		CreateUserParams	true	"Params"
//	@Success	201			{object}	models.User
//	@Failure	400,401,500	{object}	middleware.ApiError
//	@Router		/users [post]
func (c *UserController) Create(
	params CreateUserParams,
	_ *gin.Context,
) (models.User, error) {
	var hash string
	if params.Password != "" {
		var err error
		hash, err = password.Hash(params.Password)
		if err != nil {
			return models.User{},
				httputil.NewError(httputil.BadRequest, err)
		}
	}

	uid, err := uuid.NewRandom()
	if err != nil {
		return models.User{},
			httputil.NewError(httputil.BadRequest, err)
	}

	sub := params.Subject
	if sub == "" {
		sub = uid.String()
	}

	user := models.User{
		BaseModel: models.BaseModel{
			ID: uid,
		},
		Subject:        sub,
		Email:          params.Email,
		HashedPassword: hash,
		Profile: models.Profile{
			Name: params.Name,
		},
	}

	err = c.db.Create(&user).Error

	if err != nil && duplicateEmailRegex.MatchString(err.Error()) {
		return models.User{}, httputil.NewErrorMsg(
			httputil.EmailAlreadyRegistered,
			"a user with the given email already exists",
		)
	}

	return user, err
}

type UpdateUserParams struct {
	models.Profile
	Email    string          `json:"email" binding:"omitempty,email"`
	Location models.Location `json:"location"`
}

// Updates a user.
//
//	@Summary	Update a user by Id and return it
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id					path		string				true	"User Id"	Format(UUID)
//	@Param		params				body		UpdateUserParams	true	"Params"
//	@Success	200					{object}	UserResponse
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/users/{id} [put]
func (c *UserController) Update(
	id string,
	params UpdateUserParams,
	ctx *gin.Context,
) (UserResponse, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return UserResponse{}, err
	}

	userId, err := uuid.Parse(id)
	if err != nil {
		return UserResponse{},
			httputil.NewError(httputil.BadRequest, err)
	}

	profile := params.Profile
	profile.Location = params.Location
	userParams := models.User{
		BaseModel: models.BaseModel{ID: userId},
		Email:     params.Email,
		Profile:   profile,
	}

	if ok := c.acl.Authorize(
		user, "update", userParams,
	); !ok {
		return UserResponse{}, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	if err = validateUpdateUserParams(params, user); err != nil {
		return UserResponse{}, err
	}

	if err = c.db.Transaction(func(tx *gorm.DB) error {
		if userParams.Volunteer != nil {
			userParams.Volunteer.UserID = userId
			if err = upsertUserProfile(userParams.Volunteer, tx); err != nil {
				return err
			}
		}
		if userParams.Elder != nil {
			userParams.Verified = true
			userParams.Elder.UserID = userId
			if err = upsertUserProfile(userParams.Elder, tx); err != nil {
				return err
			}
		}

		result := tx.Model(&userParams).
			Omit(clause.Associations).
			Where("id = ?", id).
			Updates(&userParams)

		if result.RowsAffected == 0 {
			return resourceNotFoundErr("user")
		}
		if result.Error != nil {
			return result.Error
		}

		if err = tx.Model(&user).
			Association("Languages").
			Replace(userParams.Languages); err != nil {
			return err
		}
		if err = tx.Model(&user).
			Association("Conditions").
			Replace(userParams.Conditions); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return UserResponse{}, err
	}

	return c.Get(id, ctx)
}

func validateUpdateUserParams(params UpdateUserParams, user models.User) error {
	if params.Elder != nil && params.Volunteer != nil {
		return httputil.NewErrorMsg(
			httputil.BadRequest,
			"attributes 'elder' and 'volunteer' cannot be simultaneously defined",
		)
	}

	if params.Elder != nil && user.Volunteer != nil {
		return httputil.NewErrorMsg(
			httputil.BadRequest,
			"cannot set 'elder' attributes on a 'volunteer' user",
		)
	}

	if params.Volunteer != nil && user.Elder != nil {
		return httputil.NewErrorMsg(
			httputil.BadRequest,
			"cannot set 'volunteer' attributes on an 'elder' user",
		)
	}

	return nil
}

// upsertUserProfile creates or updates given Volunteer or Elder profile,
// including the associations.
func upsertUserProfile(dst any, db *gorm.DB) error {
	volunteer, isVolunteer := dst.(*models.Volunteer)
	elder, isElder := dst.(*models.Elder)
	if !isVolunteer && !isElder {
		panic(fmt.Errorf(
			"invalid arguments, must be *Volunteer or *Elder: %T %+v", dst, dst,
		))
	}

	if err := db.Model(dst).
		Omit(clause.Associations).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "user_id"}},
			UpdateAll: true,
		}).Create(dst).Error; err != nil {
		return err
	}

	if isVolunteer {
		if err := db.Model(volunteer).
			Association("Availabilities").
			Replace(volunteer.Availabilities); err != nil {
			return err
		}

		// Delete orphans left by the Replace function (see comment on
		// Availability model).
		db.Where("volunteer_id is null").Delete(&models.Availability{})

		if err := db.Model(volunteer).
			Association("TaskTypes").
			Replace(volunteer.TaskTypes); err != nil {
			return err
		}
	} else {
		if err := db.Model(elder).
			Association("EmergencyContacts").
			Replace(elder.EmergencyContacts); err != nil {
			return err
		}

		db.Where("elder_id is null").Delete(&models.EmergencyContact{})
	}

	return nil
}

// Verifies a user.
//
//	@Summary	Verify a user by Id
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id					path		string	true	"User Id"	Format(UUID)
//	@Success	200					{object}	UserResponse
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/users/{id}/verify [put]
func (c *UserController) Verify(
	id string,
	ctx *gin.Context,
) (UserResponse, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return UserResponse{}, err
	}

	userId, err := uuid.Parse(id)
	if err != nil {
		return UserResponse{}, httputil.NewError(httputil.BadRequest, err)
	}

	userParams := models.User{
		BaseModel: models.BaseModel{ID: userId},
		Verified:  true,
	}

	if ok := c.acl.Authorize(
		user, "verify", userParams,
	); !ok {
		return UserResponse{}, httputil.NewErrorMsg(
			httputil.AdminAccessRequired,
			httputil.AdminRequiredMessage,
		)
	}

	result := c.db.Model(&userParams).
		Omit(clause.Associations).
		Where("id = ?", id).
		Updates(&userParams)

	if result.RowsAffected == 0 {
		return UserResponse{}, resourceNotFoundErr("user")
	}

	return c.Get(id, ctx)
}

// Deletes a user.
//
//	@Summary	Delete a user by Id
//	@Tags		users
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		id	path	string	true	"User Id"	Format(UUID)
//	@Success	204
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/users/{id} [delete]
func (c *UserController) Delete(id string, ctx *gin.Context) error {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return err
	}

	userId, err := uuid.Parse(id)
	if err != nil {
		return httputil.NewError(httputil.BadRequest, err)
	}

	if ok := c.acl.Authorize(
		user, "delete", models.User{
			BaseModel: models.BaseModel{ID: userId},
		},
	); !ok {
		return httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	result := c.db.Delete(&models.User{}, "id = ?", id)
	if result.RowsAffected == 0 {
		return resourceNotFoundErr("user")
	}
	return result.Error
}
