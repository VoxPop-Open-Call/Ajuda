package logger

import "log"

const (
	Silent = iota
	Error
	Info
	Debug
)

type Logger struct {
	Level  int
	Prefix string
}

func (l *Logger) Logf(level int, format string, a ...any) {
	if l.Level >= level {
		log.Printf(l.Prefix+": "+format, a...)
	}
}

func (l *Logger) Errorf(format string, a ...any) {
	l.Logf(Error, format, a...)
}

func (l *Logger) Infof(format string, a ...any) {
	l.Logf(Info, format, a...)
}

func (l *Logger) Debugf(format string, a ...any) {
	l.Logf(Debug, format, a...)
}
