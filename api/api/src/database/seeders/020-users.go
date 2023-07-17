package seeders

import (
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"gorm.io/gorm"
)

type user struct{}

var User user

func (user) Seed(db *gorm.DB) {
	var taskTypes []models.TaskType
	db.Limit(5).Order("code asc").Find(&taskTypes)

	var conditions []models.Condition
	db.Limit(4).Order("code asc").Find(&conditions)

	var users = []models.User{
		{
			Profile: models.Profile{
				Name:      "Stan Marsh",
				Birthday:  types.DatePtr("1997-08-13"),
				Gender:    "M",
				Languages: []models.Language{{Code: "en"}},
				Location: models.Location{
					Address: "Tegrity Farms",
					Lat:     39,
					Long:    -105,
					Radius:  40,
				},
				Volunteer: &models.Volunteer{
					TaskTypes: taskTypes[:3],
					Availabilities: []models.Availability{
						{
							WeekDay: time.Monday,
							Start:   "08:00Z",
							End:     "20:00Z",
						},
						{
							WeekDay: time.Wednesday,
							Start:   "08:00Z",
							End:     "20:00Z",
						},
						{
							WeekDay: time.Friday,
							Start:   "09:30Z",
							End:     "13:00Z",
						},
						{
							WeekDay: time.Saturday,
							Start:   "09:30Z",
							End:     "15:00Z",
						},
					},
				},
			},
			Email:          "stanley@tegrityfarms.com",
			Verified:       true,
			Subject:        random.String(20),
			HashedPassword: "$2a$10$D9GbC0NrCIf2/gtTTzX87eoZ3J6Z/gt4NxtyS.SbRD4UVR1l6Y60q",
		},
		{
			Profile: models.Profile{
				Name:     "Alice",
				Birthday: types.DatePtr("1969-01-20"),
				Gender:   "F",
				Languages: []models.Language{
					{Code: "pt"},
					{Code: "fr"},
				},
				Conditions: []models.Condition{
					conditions[0], conditions[1], conditions[2],
				},
				Elder: &models.Elder{
					EmergencyContacts: []models.EmergencyContact{
						{
							Name:        "Mathew Stephens",
							PhoneNumber: "6-(282)351-6764",
						},
						{
							Name:        "Angela Stephens",
							PhoneNumber: "6-(643)746-8652",
						},
					},
				},
			},
			Email:          "alice@example.com",
			Verified:       true,
			Subject:        random.String(20),
			HashedPassword: "$2a$10$TtpOQuvqqcgcCflgzp3gKeCIU2kKKP7i95bWva0qwVnf1Ehv7NFVe",
		},
		{
			Profile: models.Profile{
				Name:      "Bob",
				Birthday:  types.DatePtr("1950-12-29"),
				Gender:    "M",
				Languages: []models.Language{{Code: "en"}},
				Conditions: []models.Condition{
					conditions[1], conditions[2], conditions[3],
				},
				Elder: &models.Elder{
					EmergencyContacts: []models.EmergencyContact{
						{
							Name:        "Sharon Meyer",
							PhoneNumber: "6-(181)351-4279",
						},
					},
				},
			},
			Email:          "bob@builders.gov",
			Verified:       true,
			Subject:        random.String(20),
			HashedPassword: "$2a$10$PCDN5RlNbLZ51R3NfQEAl.tDBGXmEXYhAqH5cn0u/BkgtHp8hikK2",
		},
		{
			Profile: models.Profile{
				Name:     "Carl Sagan",
				Birthday: types.DatePtr("1934-11-09"),
				Gender:   "M",
			},
			Subject: random.String(20),
			Email:   "test@example.com",
		},
		{
			// user returned by Dex's mock connector
			Email:    "kilgore@kilgore.trout",
			Verified: true,
			Subject:  "Cg0wLTM4NS0yODA4OS0wEgRtb2Nr",
			Profile: models.Profile{
				Name:     "Kilgore Trout",
				Birthday: types.DatePtr("2000-01-01"),
				Gender:   "X",
				Languages: []models.Language{
					{Code: "en"},
					{Code: "pt"},
					{Code: "fr"},
					{Code: "psr"},
				},
				Volunteer: &models.Volunteer{
					TaskTypes: taskTypes[3:],
					Availabilities: []models.Availability{
						{
							WeekDay: time.Wednesday,
							Start:   "10:00Z",
							End:     "22:00Z",
						},
					},
				},
			},
		},
		{
			Profile: models.Profile{
				Name:     "John Doe",
				Birthday: types.DatePtr("2010-01-01"),
				Volunteer: &models.Volunteer{
					TaskTypes: taskTypes[1:4],
					Availabilities: []models.Availability{
						{
							WeekDay: time.Thursday,
							Start:   "18:00Z",
							End:     "20:00Z",
						},
						{
							WeekDay: time.Friday,
							Start:   "18:00Z",
							End:     "20:00Z",
						},
					},
				},
			},
			Email:          "johndoe@test.com",
			Subject:        random.String(20),
			HashedPassword: "$2a$10$PCDN5RlNbLZ51R3NfQEAl.tDBGXmEXYhAqH5cn0u/BkgtHp8hikK2",
		},
		{
			Profile: models.Profile{
				Name:     "Jenna Doe",
				Birthday: types.DatePtr("2010-01-01"),
				Gender:   "F",
			},
			Email:          "jennadoe@test.com",
			Subject:        random.String(20),
			HashedPassword: "$2a$10$PCDN5RlNbLZ51R3NfQEAl.tDBGXmEXYhAqH5cn0u/BkgtHp8hikK2",
		},
	}

	db.CreateInBatches(users, 50)
}
