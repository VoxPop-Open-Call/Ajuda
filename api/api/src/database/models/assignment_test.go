package models

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestAssignmentScan(t *testing.T) {
	for i, tc := range []struct {
		src any
		err string
		exp string
	}{
		{"pending", "", "pending"},
		{"accepted", "", "accepted"},
		{"rejected", "", "rejected"},
		{"", "", ""},
		{"invalid", "invalid value for AssignmentState: invalid", ""},
		{[]byte("pending"), "", "pending"},
		{[]byte("accepted"), "", "accepted"},
		{[]byte("rejected"), "", "rejected"},
		{[]byte(""), "", ""},
		{[]byte("invalid"), "invalid value for AssignmentState: invalid", ""},
	} {
		ms := new(AssignmentState)
		err := ms.Scan(tc.src)
		if tc.err == "" {
			assert.NoError(t, err, "failed test case %d", i)
		} else {
			assert.EqualError(t, err, tc.err, "failed test case %d", i)
		}
		assert.Equal(t, tc.exp, string(*ms), "failed test case %d", i)
	}
}

func TestAssignmentValue(t *testing.T) {
	for i, tc := range []struct {
		ms  AssignmentState
		err string
		exp string
	}{
		{"pending", "", "pending"},
		{"accepted", "", "accepted"},
		{"rejected", "", "rejected"},
		{"", "", ""},
		{"invalid", "invalid value for AssignmentState: invalid", ""},
	} {
		val, err := tc.ms.Value()
		if tc.err == "" {
			assert.NoError(t, err, "failed test case %d", i)
		} else {
			assert.EqualError(t, err, tc.err, "failed test case %d", i)
		}
		assert.Equal(t, tc.exp, val, "failed test case %d", i)
	}
}
