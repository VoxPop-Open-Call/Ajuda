package stringutil

// Ellipsis truncates s to length n, including ellipsis.
func Ellipsis(s string, n uint) string {
	if n <= 3 {
		return s[:n]
	}
	if uint(len(s)) <= n {
		return s
	}
	return s[:n-3] + "..."
}
