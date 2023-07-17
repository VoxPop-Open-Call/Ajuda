package models

import (
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Volunteer contains the profile fields exclusive to volunteers.
type Volunteer struct {
	ID uuid.UUID `json:"-" gorm:"primaryKey;type:uuid;default:gen_random_uuid()"`

	// Availability windows are replaced when updating the volunteer.
	Availabilities []Availability `json:"availabilities,omitempty" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`

	// TaskTypes are replaced when updating the volunteer.
	//
	// To create a new task type, provide only the TaskType.Code. Otherwise,
	// use the TaskType.ID to identify it.
	TaskTypes []TaskType `json:"taskTypes,omitempty" gorm:"many2many:user_task_types;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`

	UserID uuid.UUID `json:"-" gorm:"unique;not null"`
	User   User      `json:"-"`
}

func (Volunteer) Migrate(db *gorm.DB) error {
	if db.Migrator().HasConstraint(&Volunteer{}, "fk_volunteers_user") {
		return nil
	}

	return db.Exec(`
		ALTER TABLE volunteers
		ADD CONSTRAINT fk_volunteers_user
		FOREIGN KEY (user_id)
		REFERENCES users(id)
		ON UPDATE CASCADE ON DELETE CASCADE
	`).Error
}

// IsAvailableOn checks whether the volunteer is available on the specified day
// of the week.
func (v Volunteer) IsAvailableOn(
	weekDay time.Weekday,
	start *types.TimeTZ,
	end *types.TimeTZ,
) bool {
	framesOnWeekDay := make([]Availability, 0, len(v.Availabilities))

	for _, availability := range v.Availabilities {
		if availability.WeekDay == weekDay {
			framesOnWeekDay = append(framesOnWeekDay, availability)
		}
	}

	if start == nil && end == nil {
		return len(framesOnWeekDay) > 0
	}
	if start == nil {
		start = end
	} else if end == nil {
		end = start
	}

	for _, availability := range framesOnWeekDay {
		if availability.Contains(*start, *end) {
			return true
		}
	}

	return false
}

// IsAvailableAt checks whether the volunteer is available at the specified time
// frame.
//
// If start and end are nil, it will return whether the volunteer is available
// on the day of the week of the given date.
func (v Volunteer) IsAvailableAt(
	date types.Date,
	start *types.TimeTZ,
	end *types.TimeTZ,
) bool {
	weekDay := date.Time().Weekday()
	return v.IsAvailableOn(weekDay, start, end)
}
