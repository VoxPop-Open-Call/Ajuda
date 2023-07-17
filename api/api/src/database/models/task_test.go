package models

import (
	"testing"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"github.com/stretchr/testify/assert"
)

func TestTaskTimeEnd(t *testing.T) {
	for i, tc := range []struct {
		task Task
		exp  string
	}{
		{
			Task{Date: "2023-06-15"},
			"2023-06-15T00:00:00Z",
		},
		{
			Task{
				Date:     "2023-06-15",
				TimeFrom: types.TimeTZPtr("06:30+02:00"),
			},
			"2023-06-15T06:30:00+02:00",
		},
		{
			Task{
				Date:     "2023-12-01",
				TimeFrom: types.TimeTZPtr("18:50Z"),
			},
			"2023-12-01T18:50:00Z",
		},
	} {
		startTime, err := tc.task.StartTime()
		assert.NoError(t, err, "failed on test %d", i)
		assert.Equal(
			t,
			tc.exp,
			startTime.Format(time.RFC3339),
			"failed on test %d", i,
		)
	}
}
