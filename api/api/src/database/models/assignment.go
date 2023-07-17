package models

import (
	"database/sql/driver"
	"fmt"

	"github.com/google/uuid"
)

// Assignment represents the connection between a Task and a potential
// volunteer.
//
// The State may be pending, accepted or rejected. There is at most one
// accepted assignment per task.
type Assignment struct {
	BaseModel
	State   AssignmentState `json:"state" gorm:"type:varchar(8);not null;default:pending;uniqueIndex:idx_unique_accepted,where:state = 'accepted'" binding:"oneof=pending accepted rejected" example:"pending"`
	Rating  int             `json:"rating,omitempty" gorm:"type:smallint;default:null;"`
	Comment string          `json:"comment,omitempty"`

	TaskID uuid.UUID `json:"taskId" gorm:"not null;uniqueIndex:idx_task_user;uniqueIndex:idx_unique_accepted,where:state = 'accepted'"`
	Task   *Task     `json:"task,omitempty"`

	UserID uuid.UUID `json:"userId" gorm:"uniqueIndex:idx_task_user;not null"`
	User   User      `json:"-" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}

// AssignmentState can be empty, "pending", "accepted" or "rejected".
type AssignmentState string

// Scan implements sql.Scanner so that AssignmentStates can be read from a
// database.
// Database types that map to string and []byte are supported.
func (s *AssignmentState) Scan(src any) error {
	var val string
	if s, ok := src.(string); ok {
		val = s
	} else if b, ok := src.([]byte); ok {
		val = string(b)
	} else {
		return fmt.Errorf("unable to scan type %T into AssignmentState", src)
	}

	if !isValidAssignmentState(val) {
		return fmt.Errorf("invalid value for AssignmentState: %s", val)
	}

	*s = AssignmentState(val)
	return nil
}

// Value implements sql.Valuer so that AssignmentStates can be written to a
// database.
// AssignmentState maps to string.
func (s AssignmentState) Value() (driver.Value, error) {
	if !isValidAssignmentState(string(s)) {
		return "", fmt.Errorf("invalid value for AssignmentState: %s", s)
	}
	return string(s), nil
}

func isValidAssignmentState(val string) bool {
	return val == "" ||
		val == "pending" || val == "accepted" || val == "rejected"
}
