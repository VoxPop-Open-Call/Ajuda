package models

import (
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"github.com/google/uuid"
)

type Availability struct {
	ID uuid.UUID `json:"-" gorm:"primaryKey;type:uuid;default:gen_random_uuid()"`

	// Documentation for `time.Weekday` can be found at https://pkg.go.dev/time#Weekday
	WeekDay time.Weekday `json:"weekDay" gorm:"type:smallint;not null"`
	Start   types.TimeTZ `json:"start" gorm:"not null" example:"12:00Z"`
	End     types.TimeTZ `json:"end" gorm:"not null" example:"12:00Z"`

	// VolunteerID cannot be set as `not null` because of:
	// https://github.com/go-gorm/gorm/issues/4010
	//
	// The gist of it is that `Association.Replace` sets the foreign key to
	// null instead of actually deleting the records.
	VolunteerID uuid.UUID `json:"-"`
}

// Contains returns whether the availability window contains the given time interval.
func (a Availability) Contains(start types.TimeTZ, end types.TimeTZ) bool {
	aStart := a.Start.Time()
	aEnd := a.End.Time()
	tStart := start.Time()
	tEnd := end.Time()
	return (aStart.Equal(tStart) || aStart.Before(tStart)) &&
		(aEnd.Equal(tEnd) || aEnd.After(tEnd))
}
