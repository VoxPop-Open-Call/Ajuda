package stringutil

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestTruncate(t *testing.T) {
	testCases := []struct {
		desc string
		n    uint
		exp  string
	}{
		{
			desc: "abcdef",
			n:    0,
			exp:  "",
		},
		{
			desc: "abcdef",
			n:    1,
			exp:  "a",
		},
		{
			desc: "abcdef",
			n:    3,
			exp:  "abc",
		},
		{
			desc: "abcdef",
			n:    6,
			exp:  "abcdef",
		},
		{
			desc: "abcdefghijklm",
			n:    6,
			exp:  "abc...",
		},
		{
			desc: "Quaerat rerum pariatur modi. Pariatur inventore ipsa officia earum consequatur quis reprehenderit. Aut et ea repellendus temporibus assumenda totam voluptas iure.",
			n:    100,
			exp:  "Quaerat rerum pariatur modi. Pariatur inventore ipsa officia earum consequatur quis reprehenderit...",
		},
		{
			desc: "abcdef",
			n:    30,
			exp:  "abcdef",
		},
	}
	for _, tC := range testCases {
		t.Run(fmt.Sprint(tC.desc, tC.n), func(t *testing.T) {
			assert.Equal(t, tC.exp, Ellipsis(tC.desc, tC.n))
		})
	}
}
