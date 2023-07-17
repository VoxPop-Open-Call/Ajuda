package controllers

import (
	"testing"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/access"
	"github.com/stretchr/testify/assert"
)

func TestMetricsAcl(t *testing.T) {
	acl := access.New()
	registerAllRules(&MetricsController{}, acl)

	testcases := []struct {
		ent, res any
		action   string
		exp      bool
	}{
		{
			ent:    models.User{Admin: true},
			res:    query.UserMetrics{},
			action: "get",
			exp:    true,
		},
		{
			ent:    models.User{},
			res:    query.UserMetrics{},
			action: "get",
			exp:    false,
		},
		{
			ent:    models.User{Admin: true},
			res:    query.TaskMetrics{},
			action: "get",
			exp:    true,
		},
		{
			ent:    models.User{},
			res:    query.TaskMetrics{},
			action: "get",
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