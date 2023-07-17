package random

import (
	"math/rand"
	"strings"
	"time"
)

func init() {
	rand.Seed(time.Now().UnixNano())
}

func Int(min, max int) int {
	return min + rand.Intn(max-min+1)
}

const alphabet = "abcdefghijklmnopqrstuvwxyz"
const uAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const numbers = "0123456789"
const alphanum = alphabet + uAlphabet + numbers

func stringFrom(n int, set string) string {
	var sb strings.Builder
	k := len(set)

	for i := 0; i < n; i++ {
		c := set[rand.Intn(k)]
		sb.WriteByte(c)
	}

	return sb.String()
}

func String(n int) string {
	return stringFrom(n, alphabet)
}

func AlphanumericString(n int) string {
	return stringFrom(n, alphanum)
}

func Bool() bool {
	return rand.Intn(2) == 0
}
