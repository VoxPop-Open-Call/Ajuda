package numutil

import "math"

// Round v to d decimal places.
func Round(v float64, d int) float64 {
	pow := math.Pow(10, float64(d))
	return math.Round(v*pow) / pow
}
