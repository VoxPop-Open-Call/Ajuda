// Package worker implements a job queue / schedule.
//
// Tasks are scheduled to perform Jobs at a given time, while a Job is a function
// that does some work.
//
// The job associated with a task will run in a goroutine. The number of
// simultaneous routines is limited by `MaxRoutineNum`.
package worker

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/util/logger"
)

const DefaultPollingSleepTime = 500 * time.Millisecond
const DefaultGlobalTimeout = 15 * time.Minute

var (
	// MaxRoutineNum is the maximum number of simultaneous goroutines.
	// Changing this value will not alter any workers already created.
	MaxRoutineNum = 5
)

type JobMap map[string]*Job

type Worker struct {
	logger.Logger
	// How long to sleep after polling the queue for new tasks.
	PollingSleepTime time.Duration
	// How long to wait for an available goroutine. It panics when this time is reached.
	GlobalTimeout time.Duration
	queue         Queue
	jobs          JobMap
	sem           chan int        // to limit the number of simultaneous goroutines
	quit          chan struct{}   // to communicate to the worker when to stop
	wg            *sync.WaitGroup // to wait for all routines to return, when quitting
	lastTask      *Task
}

// New creates a new Worker for the given queue.
func New(queue Queue) *Worker {
	return &Worker{
		Logger:           logger.Logger{Level: logger.Info, Prefix: "worker"},
		PollingSleepTime: DefaultPollingSleepTime,
		GlobalTimeout:    DefaultGlobalTimeout,
		queue:            queue,
		jobs:             make(JobMap),
		sem:              make(chan int, MaxRoutineNum),
		quit:             make(chan struct{}, 1),
		wg:               &sync.WaitGroup{},
	}
}

// Register the given jobs with the worker.
// Each job name should have less than 20 characters, and an existing job with
// the same name will be replaced.
func (w *Worker) Register(jobs ...*Job) error {
	var err error
	for _, job := range jobs {
		err = w.register(job)
		if err != nil {
			return err
		}
	}
	return nil
}

func (w *Worker) register(job *Job) error {
	if len(job.Name) > 20 {
		return fmt.Errorf("job name '%s' too long, 20 characters max", job.Name)
	}

	if job.Handler == nil {
		return fmt.Errorf("job handler for '%s' is nil", job.Name)
	}

	job.calculateDelayFunc()
	w.jobs[job.Name] = job
	return nil
}

// Schedule a task with the provided configuration.
func (w *Worker) Schedule(conf *TaskConfig) error {
	if _, ok := w.jobs[conf.JobName]; !ok {
		return fmt.Errorf("the job '%s' isn't registered", conf.JobName)
	}

	if conf.ScheduledTo.IsZero() {
		conf.ScheduledTo = time.Now()
	}

	return w.queue.Enqueue(&Task{TaskConfig: *conf})
}

// Run starts polling the queue and running tasks.
func (w *Worker) Run() {
	for {
		select {
		case <-w.quit:
			return
		default:
			w.update()
			time.Sleep(w.PollingSleepTime)
		}
	}
}

func (w *Worker) update() {
	w.Debugf("polling")
	task, todo, err := w.queue.Poll()
	if err != nil {
		w.Errorf("error polling the queue: %v", err)
		return
	}

	if todo {
		select {
		case w.sem <- 1:
			w.wg.Add(1)
			go func() {
				w.handle(task)
				<-w.sem
				w.wg.Done()
			}()
		case <-time.After(w.GlobalTimeout):
			panic(
				fmt.Sprintf("worker timeout, last running task: %+v", w.lastTask),
			)
		}
	}
}

func (w *Worker) handle(task *Task) {
	job, ok := w.jobs[task.JobName]
	if !ok {
		panic(fmt.Sprintf("job '%s' is not registered", task.JobName))
	}

	w.lastTask = task

	w.Infof("running task: %s", task)
	ctx := context.Background()
	err := job.Handler(ctx, task.Args)

	if err == nil {
		w.Infof("task completed: %s", task)
		w.dequeue(task)

		if job.OnSuccess != nil {
			w.Infof("calling '%s' OnSuccess callback", task)
			job.OnSuccess()
		}
	} else {
		w.Errorf("error running '%s': %v", task, err)

		if task.Tries < job.Retries {
			retryTime := time.Now().Add(job.nextDelay(task.Tries))
			w.Infof("rescheduling '%s' to: %s", task, retryTime)

			w.reschedule(task, retryTime)
		} else {
			w.Errorf("discarding '%s', no more retries", task)
			w.dequeue(task)

			if job.OnFailure != nil {
				w.Infof("calling '%s' OnFailure callback", task)
				job.OnFailure()
			}
		}
	}
}

// Stop this worker.
// Waits for the currently running routines to finish.
func (w *Worker) Stop(ctx context.Context) error {
	w.Infof("stopping")
	close(w.quit)

	w.Infof("waiting for running tasks")
	ch := make(chan struct{})
	go func() {
		defer close(ch)
		w.wg.Wait()
	}()

	select {
	case <-ch:
	case <-ctx.Done():
		return errors.New("timeout waiting for running tasks, stopping anyway")
	}

	w.Infof("stopped")
	return nil
}

func (w *Worker) dequeue(task *Task) {
	err := w.queue.Dequeue(task)
	if err != nil {
		w.Errorf("error deleting '%s': %v", task, err)
	}
}

func (w *Worker) reschedule(task *Task, to time.Time) {
	err := w.queue.Reschedule(task, to)
	if err != nil {
		w.Errorf("error rescheduling '%s': %v", task, err)
	}
}
