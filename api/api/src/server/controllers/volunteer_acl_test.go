package controllers

import (
	"testing"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"github.com/stretchr/testify/assert"
)

func TestVolunteerAcl(t *testing.T) {
	acl := access.New()
	registerAllRules(&VolunteerController{}, acl)

	for i, tc := range []struct {
		ent    models.User
		res    []models.Volunteer
		action string
		exp    bool
	}{
		{
			ent: models.User{
				Profile: models.Profile{
					Elder: &models.Elder{},
				},
			},
			res:    []models.Volunteer{},
			action: "list",
			exp:    true,
		},
		{
			ent: models.User{
				Profile: models.Profile{
					Volunteer: &models.Volunteer{},
				},
			},
			res:    []models.Volunteer{},
			action: "list",
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
