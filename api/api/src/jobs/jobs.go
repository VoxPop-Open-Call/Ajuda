// Package jobs defines Jobs to be run by the job queue.
// See package `worker`.
package jobs

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/firebase"
	"bitbucket.org/mobinteg/ajuda-mais/src/worker"
	"gorm.io/gorm"
)

// All initializes and returns all jobs, to be registered with a worker.
func All(
	wrkr *worker.Worker,
	fbase *firebase.Firebase,
	db *gorm.DB,
) []*worker.Job {
	return []*worker.Job{
		fcmNotify(fbase.Fcm, db),
		fcmMulticast(fbase.Fcm, db),
		fcmCleanup(wrkr, fbase.Fcm, db),
		passwordResetCodeCleanup(wrkr, db),
		fetchEvents(wrkr, db),
		fetchNews(wrkr, db),
	}
}
