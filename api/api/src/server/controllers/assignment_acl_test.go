package controllers

import (
	"testing"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAssignmentAcl(t *testing.T) {
	acl := access.New()
	registerAllRules(&AssignmentController{}, acl)

	uid1, err := uuid.NewRandom()
	require.NoError(t, err)
	uid2, err := uuid.NewRandom()
	require.NoError(t, err)

	testcases := []struct {
		ent, res any
		action   string
		exp      bool
	}{
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid1}},
			res:    models.Assignment{UserID: uid1, State: "pending"},
			action: "change-state",
			exp:    true,
		},
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid1}},
			res:    models.Assignment{UserID: uid1, State: "rejected"},
			action: "change-state",
			exp:    false,
		},
		{
			ent:    models.User{BaseModel: models.BaseModel{ID: uid1}},
			res:    models.Assignment{UserID: uid2, State: "pending"},
			action: "change-state",
			exp:    false,
		},
		{
			ent: models.User{BaseModel: models.BaseModel{ID: uid1}},
			res: models.Assignment{UserID: uid1, Task: &models.Task{
				RequesterID: uid1,
			}},
			action: "create",
			exp:    true,
		},
		{
			ent: models.User{BaseModel: models.BaseModel{ID: uid1}},
			res: models.Assignment{UserID: uid1, Task: &models.Task{
				RequesterID: uid2,
			}},
			action: "create",
			exp:    false,
		},
		{
			ent: models.User{BaseModel: models.BaseModel{ID: uid1}},
			res: models.Assignment{
				UserID: uid1,
				State:  "accepted",
				Task:   &models.Task{RequesterID: uid1},
			},
			action: "review",
			exp:    true,
		},
		{
			ent: models.User{BaseModel: models.BaseModel{ID: uid1}},
			res: models.Assignment{
				UserID: uid1,
				State:  "accepted",
				Task:   &models.Task{RequesterID: uid2},
			},
			action: "review",
			exp:    false,
		},
		{
			ent: models.User{BaseModel: models.BaseModel{ID: uid1}},
			res: models.Assignment{
				UserID: uid1,
				State:  "rejected",
				Task:   &models.Task{RequesterID: uid1},
			},
			action: "review",
			exp:    false,
		},
	}

	for i, tc := range testcases {
		assert.Equal(
			t,
			tc.exp,
			acl.Authorize(tc.ent, tc.action, tc.res),
			"failed for test case %d", i,
		)
	}
}
