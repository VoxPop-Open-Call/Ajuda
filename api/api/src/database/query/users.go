package query

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/middleware"
	"gorm.io/gorm"
)

type users struct{}

var Users users

// WithAssociations prepares a query for the users in the database with the
// necessary associations.
func (users) WithAssociations(db *gorm.DB) (tx *gorm.DB) {
	return db.Model(&models.User{}).
		Preload("Languages").
		Preload("Conditions").
		Preload("Volunteer.Availabilities").
		Preload("Volunteer.TaskTypes").
		Preload("Elder.EmergencyContacts").
		Joins("Volunteer").
		Joins("Elder")
}

// FromClaims retrieves the user identified by the given claims.
func (users) FromClaims(
	claims *middleware.Claims,
	db *gorm.DB,
) (models.User, error) {
	var user models.User
	err := db.
		Preload("Languages").
		Joins("Volunteer").
		Joins("Elder").
		Where("subject = ?", claims.Sub).
		Or("subject = ?", claims.Name).
		First(&user).Error

	return user, err
}

func (users) ByEmail(email string, db *gorm.DB) (models.User, error) {
	var user models.User
	err := db.First(&user, "email = ?", email).Error
	return user, err
}

type RatingData struct {
	AverageRating float64 `json:"averageRating,omitempty" example:"4.5"`

	// ReviewCount is the total number of reviews for the user.
	ReviewCount int `json:"reviewCount" example:"7"`
}

// Rating retrieves the average review rating of the user with the given id.
func (users) Rating(userId string, db *gorm.DB) (RatingData, error) {
	var data RatingData
	err := db.
		Table("assignments").
		Select("avg(rating) as average_rating, count(*) as review_count").
		Where("user_id = ? and rating is not null", userId).
		Scan(&data).Error

	return data, err
}

// Reviews prepares a query for the reviews of the user with the given id.
func (users) Reviews(userId string, db *gorm.DB) (tx *gorm.DB) {
	return db.
		Model(&models.Assignment{}).
		Preload("Task").
		Preload("Task.Requester").
		Preload("Task.TaskType").
		Where("user_id = ? and rating is not null", userId)
}

// Volunteers prepares a query for the volunteer users in the database.
//
// Only verified users will be retrieved.
// A search can be optionally performed, which will match the user's email or
// name (case-insensitive).
func (users) Volunteers(search string, db *gorm.DB) (tx *gorm.DB) {
	return Users.WithAssociations(db).
		Joins("INNER JOIN volunteers ON users.id = volunteers.user_id").
		Order("id asc").
		Where("verified = true").
		Where("email ilike $1 or name ilike $1", "%"+search+"%")
}
