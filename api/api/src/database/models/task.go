package models

import (
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"github.com/google/uuid"
)

type Task struct {
	BaseModel
	Description string        `json:"description"`
	Date        types.Date    `json:"date" gorm:"not null" example:"2023-03-30"`
	TimeFrom    *types.TimeTZ `json:"timeFrom,omitempty" gorm:"default:null" example:"12:00Z"`
	TimeTo      *types.TimeTZ `json:"timeTo,omitempty" gorm:"default:null" example:"13:30Z"`
	Canceled    bool          `json:"canceled" gorm:"not null;default:false"`

	Assignments []Assignment `json:"assignments,omitempty" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`

	RequesterID uuid.UUID `json:"requesterId" gorm:"not null;foreignKey:Requester"`
	Requester   User      `json:"requester" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`

	TaskTypeID uuid.UUID `json:"taskTypeId" gorm:"not null"`
	TaskType   TaskType  `json:"taskType" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}

// StartTime returns the time.Time corresponding to the start of the task,
// parsed from the Date and TimeFrom fields.
func (t Task) StartTime() (time.Time, error) {
	format := types.DateFormat + " "
	fromStr := ""
	if t.TimeFrom != nil {
		format += types.TimeTZFormat
		fromStr = string(*t.TimeFrom)
	}

	return time.Parse(
		format,
		string(t.Date)+" "+fromStr)
}
