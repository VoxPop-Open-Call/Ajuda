package query

import (
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"gorm.io/gorm"
)

type assignments struct{}

var Assignments assignments

func (assignments) Create(
	task models.Task,
	user models.User,
	db *gorm.DB,
) (models.Assignment, error) {
	assignment := models.Assignment{
		Task: &task,
		User: user,
	}

	err := db.Create(&assignment).Error
	return assignment, err
}

// ForUser prepares a query for the assignments of the user with the given id.
func (assignments) ForUser(userId string, db *gorm.DB) (tx *gorm.DB) {
	return db.Model(&models.Assignment{}).
		Where("user_id = ?", userId).
		Preload("Task.TaskType").
		Preload("Task.Requester").
		Joins("Task")
}

// Upcoming prepares a query for the assignments whose starting time is later
// than the current time.
func (assignments) Upcoming(db *gorm.DB) (tx *gorm.DB) {
	now := time.Now()
	return db.Where(
		`"Task".date > '` + now.Format(types.DateFormat) + "' or (" +
			`"Task".date = '` + now.Format(types.DateFormat) + "' and (" +
			`"Task".time_from is NULL or ` +
			`"Task".time_from > '` + now.Format(types.TimeTZFormat) + "'" +
			"))",
	)
}

// Completed prepares a query for the assignments whose ending time is earlier
// than the current time.
func (assignments) Completed(db *gorm.DB) (tx *gorm.DB) {
	now := time.Now()
	return db.Where(
		`"Task".date < '` + now.Format(types.DateFormat) + "' or (" +
			`"Task".date = '` + now.Format(types.DateFormat) + "' and " +
			`"Task".time_to < '` + now.Format(types.TimeTZFormat) + "'" +
			")",
	)
}
