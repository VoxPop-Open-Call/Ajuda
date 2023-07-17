package models

import (
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"github.com/stretchr/testify/assert"
)

func TestVolunteerIsAvailable(t *testing.T) {
	for i, tc := range []struct {
		volunteer  Volunteer
		date       types.Date
		start, end *types.TimeTZ
		exp        bool
	}{
		{
			volunteer: Volunteer{},
			date:      "2023-10-12",
			exp:       false,
		},
		{
			volunteer: Volunteer{
				Availabilities: nil,
			},
			date: types.Date("2023-05-05"),
			exp:  false,
		},
		{
			volunteer: Volunteer{
				Availabilities: []Availability{
					{
						WeekDay: time.Monday,
						Start:   "18:00Z",
						End:     "21:00Z",
					},
				},
			},
			date: "2023-04-10", // monday
			exp:  true,
		},
		{
			volunteer: Volunteer{
				Availabilities: []Availability{
					{
						WeekDay: time.Monday,
						Start:   "18:00Z",
						End:     "21:00Z",
					},
				},
			},
			date:  "2023-04-10", // monday
			start: types.TimeTZPtr("19:00Z"),
			end:   types.TimeTZPtr("21:00Z"),
			exp:   true,
		},
		{
			volunteer: Volunteer{
				Availabilities: []Availability{
					{
						WeekDay: time.Monday,
						Start:   "18:00Z",
						End:     "21:00Z",
					},
				},
			},
			date:  "2023-04-10", // monday
			start: types.TimeTZPtr("19:00Z"),
			end:   types.TimeTZPtr("22:00Z"),
			exp:   false,
		},
		{
			volunteer: Volunteer{
				Availabilities: []Availability{
					{
						WeekDay: time.Monday,
						Start:   "18:00Z",
						End:     "21:00Z",
					},
					{
						WeekDay: time.Wednesday,
						Start:   "08:30Z",
						End:     "10:00Z",
					},
					{
						WeekDay: time.Wednesday,
						Start:   "18:00Z",
						End:     "23:00Z",
					},
				},
			},
			date:  "2023-04-12", // wednesday
			start: types.TimeTZPtr("19:00Z"),
			end:   types.TimeTZPtr("22:00Z"),
			exp:   true,
		},
	} {
		assert.Equal(t, tc.exp, tc.volunteer.IsAvailableAt(
			tc.date,
			tc.start,
			tc.end,
		), "failed on test %d", i)
	}
}
