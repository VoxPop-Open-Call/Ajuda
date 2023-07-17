package controllers

import (
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTasksAcl(t *testing.T) {
	acl := access.New()
	registerAllRules(&TaskController{}, acl)

	uid1, err := uuid.NewRandom()
	require.NoError(t, err)
	uid2, err := uuid.NewRandom()
	require.NoError(t, err)

	for i, tc := range []struct {
		ent, res any
		action   string
		exp      bool
	}{
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid1}},
			res:    models.Task{RequesterID: uid1},
			action: "get",
			exp:    true,
		},
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid2}},
			res:    models.Task{RequesterID: uid1},
			action: "get",
			exp:    false,
		},
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid1}},
			res:    models.Task{RequesterID: uid1},
			action: "update",
			exp:    true,
		},
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid2}},
			res:    models.Task{RequesterID: uid1},
			action: "update",
			exp:    false,
		},
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid1}},
			res:    models.Task{RequesterID: uid1},
			action: "cancel",
			exp:    true,
		},
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid2}},
			res:    models.Task{RequesterID: uid1},
			action: "cancel",
			exp:    false,
		},
		{
			ent: models.User{
				BaseModel: models.BaseModel{ID: uid1},
				Profile: models.Profile{
					Elder: &models.Elder{},
				},
			},
			res:    models.Task{RequesterID: uid1},
			action: "create",
			exp:    true,
		},
		{
			ent: models.User{
				BaseModel: models.BaseModel{ID: uid1},
				Profile: models.Profile{
					Volunteer: &models.Volunteer{
						Availabilities: []models.Availability{
							{
								WeekDay: time.Wednesday,
								Start:   "08:00Z",
								End:     "20:00Z",
							},
						},
					},
				},
			},
			res:    models.Task{RequesterID: uid1},
			action: "create",
			exp:    false,
		},
	} {
		assert.Equal(
			t,
			tc.exp,
			acl.Authorize(tc.ent, tc.action, tc.res),
			"failed on test %d", i,
		)
	}
}
