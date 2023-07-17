package query

import (
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/numutil"
	"gorm.io/gorm"
)

const (
	day   = time.Hour * 24
	week  = day * 7
	month = day * 30
)

type metrics struct{}

var Metrics metrics

type AgeGroups struct {
	AgeLt18   int64 `json:"age<18"`
	Age18To25 int64 `json:"18<=age<25"`
	Age25To30 int64 `json:"25<=age<30"`
	Age30To40 int64 `json:"30<=age<40"`
	Age40To60 int64 `json:"40<=age<60"`
	Age60To75 int64 `json:"60<=age<75"`
	AgeGte75  int64 `json:"age>=75"`
}

type GenderCount struct {
	M int64 `json:"m"`
	F int64 `json:"f"`
	X int64 `json:"x"`
}

type UserMetrics struct {
	TotalUsers         int64 `json:"totalUsers"`
	TotalElders        int64 `json:"totalElders"`
	TotalVolunteers    int64 `json:"totalVolunteers"`
	TotalVerifiedUsers int64 `json:"totalVerifiedUsers"`

	// AgeGroups maps the number of users in each age range.
	AgeGroups AgeGroups `json:"ageGroups"`
	// GenderCount maps the number of users of each gender.
	GenderCount GenderCount `json:"genderCount"`
	// LanguageCount maps the number of users that speak a given language.
	LanguageCount map[string]int64 `json:"languageCount" example:"en:12,pt:20"`
}

func (metrics) Users(db *gorm.DB) (UserMetrics, error) {
	var totalUsers, totalElders, totalVolunteers, totalVerifiedUsers int64
	db.Raw("select count(*) from users").Scan(&totalUsers)
	db.Raw("select count(*) from elders").Scan(&totalElders)
	db.Raw("select count(*) from volunteers").Scan(&totalVolunteers)
	db.Raw("select count(*) from users where verified = true").Scan(&totalVerifiedUsers)

	var ages AgeGroups
	db.Raw(`
		WITH user_age AS (
			SELECT date_part('year', age(birthday)) AS age FROM users
		)
		SELECT
			count(*) filter(WHERE age<18) AS "age_lt18",
			count(*) filter(WHERE age>=18 AND age<25) AS "age18_to25",
			count(*) filter(WHERE age>=25 AND age<30) AS "age25_to30",
			count(*) filter(WHERE age>=30 AND age<40) AS "age30_to40",
			count(*) filter(WHERE age>=40 AND age<60) AS "age40_to60",
			count(*) filter(WHERE age>=60 AND age<75) AS "age60_to75",
			count(*) filter(WHERE age>=75) AS "age_gte75"
		FROM user_age
	`).Scan(&ages)

	var genders []struct {
		Gender string
		Count  int64
	}
	db.Raw(`
		SELECT gender, count(gender)
		FROM users
		GROUP BY gender
		HAVING gender IS NOT null
	`).Scan(&genders)

	var langs []struct {
		Code  string
		Count int64
	}
	db.Raw(`
		SELECT language_code AS code, count(language_code)
		FROM user_languages
		GROUP BY language_code
	`).Scan(&langs)

	return UserMetrics{
		TotalUsers:         totalUsers,
		TotalElders:        totalElders,
		TotalVolunteers:    totalVolunteers,
		TotalVerifiedUsers: totalVerifiedUsers,
		AgeGroups:          ages,
		GenderCount:        toGenderCount(genders),
		LanguageCount:      toMap(langs),
	}, db.Error
}

func toGenderCount(raw []struct {
	Gender string
	Count  int64
}) GenderCount {
	result := GenderCount{}
	for _, g := range raw {
		switch g.Gender {
		case "M":
			result.M = g.Count
		case "F":
			result.F = g.Count
		case "X":
			result.X = g.Count
		}
	}
	return result
}

type ratingBreakdown struct {
	One  int64 `json:"1"`
	Two  int64 `json:"2"`
	Tree int64 `json:"3"`
	Four int64 `json:"4"`
	Five int64 `json:"5"`
}

type TaskMetrics struct {
	// TotalTasks is the total number of tasks in the database.
	TotalTasks int64 `json:"totalTasks"`
	// TotalPendingTasks is the number of tasks that don't have an `accepted`
	// assignment (i.e. the tasks that are pending a matching volunteer).
	TotalPendingTasks int64 `json:"totalPendingTasks"`
	// TotalCompletedTasks is the number of tasks whose date is earlier than the
	// current time.
	TotalCompletedTasks int64 `json:"totalCompletedTasks"`

	// TaskTypeCount contains the most used task types and the number of
	// occurrences.
	TaskTypeCount map[string]int64 `json:"taskTypeGroups"`

	// Average number of tasks per day, since the creation of the first task in
	// the database.
	AveragePerDay float32 `json:"averagePerDay"`

	// Average number of tasks per week, since the creation of the first task
	// in the database.
	AveragePerWeek float32 `json:"averagePerWeek"`

	// Average number of tasks per month, since the creation of the first task
	// in the database.
	AveragePerMonth float32 `json:"averagePerMonth"`

	RatingBreakdown ratingBreakdown `json:"ratingBreakdown"`
}

func (metrics) Tasks(db *gorm.DB) (TaskMetrics, error) {
	var totalTasks, totalPendingTasks, totalCompletedTasks int64
	db.Raw("select count(*) from tasks").Scan(&totalTasks)

	db.Raw(`
		SELECT count(*) FROM tasks
		WHERE id NOT IN (
			SELECT task_id FROM assignments
			WHERE state = 'accepted'
		) AND date > now();
	`).Scan(&totalPendingTasks)

	db.Raw(`
		SELECT count(*) FROM tasks
		INNER JOIN assignments
		ON
			tasks.id = assignments.task_id AND
			state = 'accepted' AND
			date < now()
	`).Scan(&totalCompletedTasks)

	var taskTypeCount []struct {
		Code  string
		Count int64
	}
	db.Raw(`
		SELECT task_types.code, count(task_type_id) as count
		FROM tasks INNER JOIN task_types
		ON task_type_id = task_types.id
		GROUP BY task_types.code
		ORDER BY count desc
		LIMIT 10
	`).Scan(&taskTypeCount)

	var oldestTaskCreationDate types.Date
	db.Raw(`
		SELECT created_at FROM tasks
		ORDER BY created_at
		LIMIT 1
	`).Scan(&oldestTaskCreationDate)

	period := time.Now().Sub(oldestTaskCreationDate.Time())
	daysInPeriod := int64(period / day)
	if daysInPeriod == 0 {
		daysInPeriod = 1
	}
	weeksInPeriod := int64(period / week)
	if weeksInPeriod == 0 {
		weeksInPeriod = 1
	}
	monthsInPeriod := int64(period / month)
	if monthsInPeriod == 0 {
		monthsInPeriod = 1
	}

	var ratings ratingBreakdown
	db.Raw(`
		WITH ratings AS (
			SELECT rating FROM assignments
            WHERE rating > 0
		)
		SELECT
			count(*) filter(WHERE rating = 1) AS "one",
			count(*) filter(WHERE rating = 2) AS "two",
			count(*) filter(WHERE rating = 3) AS "three",
			count(*) filter(WHERE rating = 4) AS "four",
			count(*) filter(WHERE rating = 5) AS "five"
		FROM ratings
	`).Scan(&ratings)

	return TaskMetrics{
		TotalTasks:          totalTasks,
		TotalPendingTasks:   totalPendingTasks,
		TotalCompletedTasks: totalCompletedTasks,
		TaskTypeCount:       toMap(taskTypeCount),
		AveragePerDay: float32(numutil.Round(
			float64(totalTasks)/float64(daysInPeriod), 2,
		)),
		AveragePerWeek: float32(numutil.Round(
			float64(totalTasks)/float64(weeksInPeriod), 2,
		)),
		AveragePerMonth: float32(numutil.Round(
			float64(totalTasks)/float64(monthsInPeriod), 2,
		)),
		RatingBreakdown: ratings,
	}, nil
}

func toMap(raw []struct {
	Code  string
	Count int64
}) map[string]int64 {
	result := make(map[string]int64)
	for _, e := range raw {
		result[e.Code] = e.Count
	}
	return result
}
