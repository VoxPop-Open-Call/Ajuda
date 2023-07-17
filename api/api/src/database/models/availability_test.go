package models

import (
	"testing"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"github.com/stretchr/testify/assert"
)

func TestAvailabilityContains(t *testing.T) {
	av := Availability{
		Start: types.TimeTZ("12:00Z"),
		End:   types.TimeTZ("15:00Z"),
	}

	for i, tc := range []struct {
		start, end string
		exp        bool
	}{
		{"13:00Z", "14:00Z", true},
		{"12:00Z", "14:00Z", true},
		{"12:00Z", "15:00Z", true},
		{"14:00Z", "15:00Z", true},
		{"15:00+02:00", "16:00+02:00", true},
		{"11:00-01:00", "14:00-01:00", true},
		{"08:00Z", "10:00Z", false},
		{"08:00Z", "14:00Z", false},
		{"14:00Z", "18:00Z", false},
		{"08:00Z", "18:00Z", false},
	} {
		assert.Equal(t, tc.exp, av.Contains(
			types.TimeTZ(tc.start),
			types.TimeTZ(tc.end),
		), "failed on test %d", i)
	}
}
