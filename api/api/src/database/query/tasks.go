package query

import (
	"errors"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"gorm.io/gorm"
)

type tasks struct{}

var Tasks tasks

// All prepares a query for the tasks (and respective associations) in the
// database.
func (tasks) All(db *gorm.DB) (tx *gorm.DB) {
	return db.Model(&models.Task{}).
		Joins("Requester").
		Joins("TaskType").
		Preload("Assignments").
		Preload("Assignments.User")
}

// RequestedBy prepares a query for the tasks requested by the user with the
// given id.
func (tasks) RequestedBy(userId string, db *gorm.DB) (tx *gorm.DB) {
	return Tasks.All(db).Where("requester_id = ?", userId)
}

// Upcoming prepares a query for the tasks whose starting time is later than
// the current time.
func (tasks) Upcoming(db *gorm.DB) (tx *gorm.DB) {
	now := time.Now()
	return db.Where(
		"date > '" + now.Format(types.DateFormat) + "' or (" +
			"date = '" + now.Format(types.DateFormat) + "' and (" +
			"time_from is NULL or " +
			"time_from > '" + now.Format(types.TimeTZFormat) + "'" +
			"))",
	)
}

// Completed prepares a query for the tasks whose ending time is earlier than
// the current time.
func (tasks) Completed(db *gorm.DB) (tx *gorm.DB) {
	now := time.Now()
	return db.Where(
		"date < '" + now.Format(types.DateFormat) + "' or (" +
			"date = '" + now.Format(types.DateFormat) + "' and " +
			"time_to < '" + now.Format(types.TimeTZFormat) + "'" +
			")",
	)
}

// LatestAssignment returns the latest assignment of a task or nil if none is
// found.
func (tasks) LatestAssignment(taskID string, db *gorm.DB) (*models.Assignment, error) {
	assignment := new(models.Assignment)
	err := db.
		Joins("User").
		Where("task_id = ?", taskID).
		Order("created_at desc").
		First(assignment).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return assignment, err
}
