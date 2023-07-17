package controllers

import (
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestFilterVolunteers(t *testing.T) {
	// ----------------------- //
	// Test a single volunteer //
	// ----------------------- //
	for i, tc := range []struct {
		volunteer models.User
		filters   ListVolunteersFilters
		exp       bool // whether the volunteer is returned
	}{
		{
			exp: true,
			volunteer: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{{
							WeekDay: time.Saturday,
							Start:   "15:00Z",
							End:     "20:00Z",
						}},
					},
					Languages: []models.Language{
						{Code: "en"}, {Code: "es"}, {Code: "pt"},
					},
					Location: models.Location{ // Faro
						Lat:    37.016,
						Long:   -7.935,
						Radius: 10,
					},
				},
			},
			filters: ListVolunteersFilters{
				Date:     types.DatePtr("2023-04-15"), // Saturday
				TimeFrom: types.TimeTZPtr("17:00Z"),
				TimeTo:   types.TimeTZPtr("18:00Z"),
				Requester: models.User{
					Profile: models.Profile{
						Languages: []models.Language{{Code: "pt"}},
						Location: models.Location{ // Loulé (~17km)
							Lat:    37.15,
							Long:   -8.0,
							Radius: 10,
						},
					},
				},
			},
		},
		{
			exp: true,
			volunteer: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{{
							WeekDay: time.Saturday,
							Start:   "15:00Z",
							End:     "20:00Z",
						}},
					},
					Languages: []models.Language{
						{Code: "en"}, {Code: "es"}, {Code: "pt"},
					},
					Location: models.Location{ // Faro
						Lat:    37.016,
						Long:   -7.935,
						Radius: 10,
					},
				},
			},
			filters: ListVolunteersFilters{
				Date: types.DatePtr("2023-04-15"), // Saturday
				Requester: models.User{
					Profile: models.Profile{
						Languages: []models.Language{{Code: "pt"}},
						Location: models.Location{ // Loulé (~17km)
							Lat:    37.15,
							Long:   -8.0,
							Radius: 10,
						},
					},
				},
			},
		},
		{
			exp: false, // Should fail because of availability.
			volunteer: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{{
							WeekDay: time.Saturday,
							Start:   "15:00Z",
							End:     "20:00Z",
						}},
					},
					Languages: []models.Language{
						{Code: "en"}, {Code: "es"}, {Code: "pt"},
					},
					Location: models.Location{ // Faro
						Lat:    37.016,
						Long:   -7.935,
						Radius: 10,
					},
				},
			},
			filters: ListVolunteersFilters{
				Date:     types.DatePtr("2023-04-16"), // Sunday
				TimeFrom: types.TimeTZPtr("17:00Z"),
				TimeTo:   types.TimeTZPtr("18:00Z"),
				Requester: models.User{
					Profile: models.Profile{
						Languages: []models.Language{{Code: "pt"}},
						Location: models.Location{ // Loulé (~17km)
							Lat:    37.15,
							Long:   -8.0,
							Radius: 10,
						},
					},
				},
			},
		},
		{
			exp: false, // Should fail without languages in common.
			volunteer: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{{
							WeekDay: time.Saturday,
							Start:   "15:00Z",
							End:     "20:00Z",
						}},
					},
					Languages: []models.Language{
						{Code: "en"}, {Code: "es"}, {Code: "pt"},
					},
					Location: models.Location{ // Faro
						Lat:    37.016,
						Long:   -7.935,
						Radius: 10,
					},
				},
			},
			filters: ListVolunteersFilters{
				Date:     types.DatePtr("2023-04-15"), // Saturday
				TimeFrom: types.TimeTZPtr("17:00Z"),
				TimeTo:   types.TimeTZPtr("18:00Z"),
				Requester: models.User{
					Profile: models.Profile{
						Languages: []models.Language{{Code: "de"}},
						Location: models.Location{ // Loulé (~17km)
							Lat:    37.15,
							Long:   -8.0,
							Radius: 10,
						},
					},
				},
			},
		},
		{
			exp: false, // Should fail because the locations are too far apart.
			volunteer: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{{
							WeekDay: time.Saturday,
							Start:   "15:00Z",
							End:     "20:00Z",
						}},
					},
					Languages: []models.Language{
						{Code: "en"}, {Code: "es"}, {Code: "pt"},
					},
					Location: models.Location{ // Faro
						Lat:    37.016,
						Long:   -7.935,
						Radius: 10,
					},
				},
			},
			filters: ListVolunteersFilters{
				Date:     types.DatePtr("2023-04-15"), // Saturday
				TimeFrom: types.TimeTZPtr("17:00Z"),
				TimeTo:   types.TimeTZPtr("18:00Z"),
				Requester: models.User{
					Profile: models.Profile{
						Languages: []models.Language{{Code: "pt"}},
						Location: models.Location{ // Altura
							Lat:    37.18,
							Long:   -7.503,
							Radius: 10,
						},
					},
				},
			},
		},

		{
			exp: true,
			volunteer: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{{
							WeekDay: time.Saturday,
							Start:   "15:00Z",
							End:     "20:00Z",
						}},
					},
					Languages: []models.Language{
						{Code: "en"}, {Code: "es"}, {Code: "pt"},
					},
					Location: models.Location{ // Faro
						Lat:    37.016,
						Long:   -7.935,
						Radius: 10,
					},
				},
			},
			filters: ListVolunteersFilters{
				WeekDays: []time.Weekday{time.Saturday},
				TimeFrom: types.TimeTZPtr("17:00Z"),
				TimeTo:   types.TimeTZPtr("18:00Z"),
				Requester: models.User{
					Profile: models.Profile{
						Languages: []models.Language{{Code: "pt"}},
						Location: models.Location{ // Loulé (~17km)
							Lat:    37.15,
							Long:   -8.0,
							Radius: 10,
						},
					},
				},
			},
		},
		{
			exp: true,
			volunteer: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{{
							WeekDay: time.Saturday,
							Start:   "15:00Z",
							End:     "20:00Z",
						}},
					},
					Languages: []models.Language{
						{Code: "en"}, {Code: "es"}, {Code: "pt"},
					},
					Location: models.Location{ // Faro
						Lat:    37.016,
						Long:   -7.935,
						Radius: 10,
					},
				},
			},
			filters: ListVolunteersFilters{
				WeekDays: []time.Weekday{time.Saturday},
				Requester: models.User{
					Profile: models.Profile{
						Languages: []models.Language{{Code: "pt"}},
						Location: models.Location{ // Loulé (~17km)
							Lat:    37.15,
							Long:   -8.0,
							Radius: 10,
						},
					},
				},
			},
		},
		{
			exp: false, // Should fail because of availability.
			volunteer: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{{
							WeekDay: time.Saturday,
							Start:   "15:00Z",
							End:     "20:00Z",
						}},
					},
					Languages: []models.Language{
						{Code: "en"}, {Code: "es"}, {Code: "pt"},
					},
					Location: models.Location{ // Faro
						Lat:    37.016,
						Long:   -7.935,
						Radius: 10,
					},
				},
			},
			filters: ListVolunteersFilters{
				WeekDays: []time.Weekday{time.Sunday},
				TimeFrom: types.TimeTZPtr("17:00Z"),
				TimeTo:   types.TimeTZPtr("18:00Z"),
				Requester: models.User{
					Profile: models.Profile{
						Languages: []models.Language{{Code: "pt"}},
						Location: models.Location{ // Loulé (~17km)
							Lat:    37.15,
							Long:   -8.0,
							Radius: 10,
						},
					},
				},
			},
		},
	} {
		result := filterVolunteers([]models.User{tc.volunteer}, tc.filters)
		if tc.exp {
			// assert.Contains(t, result, tc.volunteer, "failed on test %d", i)
			assert.Len(t, result, 1, "failed on test %d", i)
			assert.Equal(t, tc.volunteer, result[0], "failed on test %d", i)
		} else {
			assert.Len(t, result, 0, "failed on test %d", i)
		}
	}

	// ------------------------ //
	// Test multiple volunteers //
	// ------------------------ //
	filters := ListVolunteersFilters{
		Date:     types.DatePtr("2023-04-15"), // Saturday
		TimeFrom: types.TimeTZPtr("17:00Z"),
		TimeTo:   types.TimeTZPtr("18:00Z"),
		Requester: models.User{
			Profile: models.Profile{
				Languages: []models.Language{{Code: "pt"}},
				Location: models.Location{
					Lat:    37.15,
					Long:   -8.0,
					Radius: 10,
				},
			},
		},
	}
	volunteers := []models.User{
		{
			Profile: models.Profile{
				Volunteer: &models.Volunteer{
					Availabilities: []models.Availability{{
						WeekDay: time.Saturday,
						Start:   "15:00Z",
						End:     "20:00Z",
					}},
				},
				Languages: []models.Language{
					{Code: "en"}, {Code: "es"}, {Code: "pt"},
				},
				Location: models.Location{
					Lat:    37.016,
					Long:   -7.935,
					Radius: 10,
				},
			},
		},
		{
			Profile: models.Profile{
				Volunteer: &models.Volunteer{
					Availabilities: []models.Availability{
						{
							WeekDay: time.Saturday,
							Start:   "10:00Z",
							End:     "12:30Z",
						},
						{
							WeekDay: time.Sunday,
							Start:   "15:00Z",
							End:     "20:00Z",
						},
					},
				},
				Languages: []models.Language{
					{Code: "pt"}, {Code: "en"},
				},
				Location: models.Location{
					Lat:    37.016,
					Long:   -7.935,
					Radius: 10,
				},
			},
		},
		{
			Profile: models.Profile{
				Volunteer: &models.Volunteer{
					Availabilities: []models.Availability{
						{
							WeekDay: time.Saturday,
							Start:   "10:00Z",
							End:     "19:00Z",
						},
						{
							WeekDay: time.Sunday,
							Start:   "15:00Z",
							End:     "20:00Z",
						},
					},
				},
				Languages: []models.Language{{Code: "pt"}},
				Location: models.Location{ // Olhão
					Lat:    37.025,
					Long:   -7.842,
					Radius: 10,
				},
			},
		},
	}
	expected := []models.User{
		volunteers[0],
		volunteers[2],
	}

	result := filterVolunteers(volunteers, filters)
	require.Equal(t, expected, result)
}
