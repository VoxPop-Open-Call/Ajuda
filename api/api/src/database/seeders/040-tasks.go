package seeders

import (
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/random"
	"gorm.io/gorm"
)

type task struct{}

var Task task

func (task) Seed(db *gorm.DB) {
	var user1 models.User
	db.First(&user1, "email = ?", "kilgore@kilgore.trout")
	var user2 models.User
	db.First(&user2, "email = ?", "stanley@tegrityfarms.com")
	var user3 models.User
	db.First(&user3, "email = ?", "alice@example.com")

	var taskTypes []models.TaskType
	db.Limit(3).Order("code asc").Find(&taskTypes)

	day := time.Hour * 24
	week := day * 7
	now := time.Now()

	tasks := []models.Task{
		{
			BaseModel: models.BaseModel{
				CreatedAt: now.Add(-3 * week),
			},
			RequesterID: user1.ID,
			Description: random.String(25),
			Date: types.Date(now.
				Add(-2 * week).
				Format(types.DateFormat)),
			TimeFrom: types.TimeTZPtr("12:00+02:00"),
			TimeTo:   types.TimeTZPtr("13:30+02:00"),
			TaskType: taskTypes[0],
			Assignments: []models.Assignment{
				{User: user2},
				{User: user3},
			},
		},
		{
			BaseModel: models.BaseModel{
				CreatedAt: now.Add(-2 * week),
			},
			RequesterID: user1.ID,
			Description: random.String(25),
			Date: types.Date(now.
				Add(-1 * week).
				Format(types.DateFormat)),
			TimeFrom: types.TimeTZPtr("12:00Z"),
			TimeTo:   types.TimeTZPtr("13:30Z"),
			TaskType: taskTypes[1],
			Assignments: []models.Assignment{
				{User: user2, State: "rejected"},
				{User: user3, State: "accepted"},
			},
		},
		{
			BaseModel: models.BaseModel{
				CreatedAt: now.Add(-10 * day),
			},
			RequesterID: user1.ID,
			Description: random.String(25),
			Date: types.Date(now.
				Add(-1 * week).
				Format(types.DateFormat)),
			TimeFrom: types.TimeTZPtr("18:00Z"),
			TimeTo:   types.TimeTZPtr("19:00Z"),
			TaskType: taskTypes[1],
			Assignments: []models.Assignment{
				{User: user2, State: "rejected"},
				{User: user3, State: "accepted"},
			},
		},
		{
			BaseModel: models.BaseModel{
				CreatedAt: now.Add(-5 * day),
			},
			RequesterID: user1.ID,
			Description: random.String(25),
			Date: types.Date(now.
				Add(-1 * day).
				Format(types.DateFormat)),
			TaskType: taskTypes[2],
		},
		{
			RequesterID: user1.ID,
			Description: random.String(25),
			Date: types.Date(now.
				Add(1 * day).
				Format(types.DateFormat)),
			TaskType: taskTypes[1],
		},
	}

	db.CreateInBatches(tasks, 50)
}
