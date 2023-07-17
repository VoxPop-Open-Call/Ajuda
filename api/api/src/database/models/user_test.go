package models

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLocationIntersects(t *testing.T) {
	for i, tc := range []struct {
		location, other Location
		exp             bool
	}{
		{
			location: Location{ // Serpa
				Lat:    37.945,
				Long:   -7.599,
				Radius: 15,
			},
			other: Location{ // Beja
				Lat:    38.033,
				Long:   -7.883,
				Radius: 15,
			},
			exp: true, // distance is roughly 28km
		},
		{
			location: Location{ // Serpa
				Lat:    37.945,
				Long:   -7.599,
				Radius: 10,
			},
			other: Location{ // Beja
				Lat:    38.033,
				Long:   -7.883,
				Radius: 15,
			},
			exp: false,
		},
		{
			location: Location{ // Lisboa
				Lat:    38.725,
				Long:   -9.15,
				Radius: 55,
			},
			other: Location{ // Entrocamento
				Lat:    39.465,
				Long:   -8.468,
				Radius: 50,
			},
			exp: true, // distance is roughly 100km (straight line)
		},
		{
			location: Location{ // Lisboa
				Lat:    38.725,
				Long:   -9.15,
				Radius: 25,
			},
			other: Location{ // Entrocamento
				Lat:    39.465,
				Long:   -8.468,
				Radius: 50,
			},
			exp: false,
		},
	} {
		assert.Equal(t, tc.exp, tc.location.Intersects(tc.other),
			"failed on test %d", i)
	}
}
