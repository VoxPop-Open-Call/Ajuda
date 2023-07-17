package firebase

import (
	"context"
	"fmt"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

type Firebase struct {
	Fcm *messaging.Client
}

// New initializes the Firebase App and Messaging Client.
func New(credentialsFile *string) (*Firebase, error) {
	opt := option.WithCredentialsFile(*credentialsFile)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		return nil, err
	}

	msg, err := app.Messaging(context.Background())
	if err != nil {
		return nil, err
	}

	return &Firebase{msg}, nil
}

// TestMessage creates a message to be used in a multicast dry-run, to test
// token validity. It's not meant to be sent to the devices.
func TestMessage(tokens []string) messaging.MulticastMessage {
	return messaging.MulticastMessage{
		Tokens: tokens,
		Data: map[string]string{
			"test": "true",
		},
	}
}

type NewAssignmentMessageConfig struct {
	TaskID        string
	RequesterName string
}

// NewAssignmentMessage is the notification sent to the volunteer when there is
// a new request to perform a task.
func NewAssignmentMessage(config NewAssignmentMessageConfig) messaging.Message {
	titleLocKey := "NEW_ASSIGNMENT_NOTIFICATION_TITLE"
	bodyLocKey := "NEW_ASSIGNMENT_NOTIFICATION_BODY"
	locArgs := []string{config.RequesterName}

	return messaging.Message{
		Data: map[string]string{
			"type":          "new-task",
			"taskId":        config.TaskID,
			"requesterName": config.RequesterName,
		},
		Android: &messaging.AndroidConfig{
			Notification: &messaging.AndroidNotification{
				TitleLocKey:  titleLocKey,
				TitleLocArgs: locArgs,
				BodyLocKey:   bodyLocKey,
				BodyLocArgs:  locArgs,
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Alert: &messaging.ApsAlert{
						TitleLocKey:  titleLocKey,
						TitleLocArgs: locArgs,
						LocKey:       bodyLocKey,
						LocArgs:      locArgs,
					},
				},
			},
		},
	}
}

type TaskCanceledMessageConfig struct {
	TaskID        string
	RequesterName string
}

// TaskCanceledMessage is the notification sent to the volunteer when a task
// assigned to them is canceled.
func TaskCanceledMessage(config TaskCanceledMessageConfig) messaging.Message {
	intent := "TASK_CANCELED_INTENT"
	titleLocKey := "TASK_CANCELED_NOTIFICATION_TITLE"
	bodyLocKey := "TASK_CANCELED_NOTIFICATION_BODY"
	locArgs := []string{config.RequesterName}

	return messaging.Message{
		Data: map[string]string{
			"type":          "task-canceled",
			"taskId":        config.TaskID,
			"requesterName": config.RequesterName,
		},
		Android: &messaging.AndroidConfig{
			Notification: &messaging.AndroidNotification{
				TitleLocKey:  titleLocKey,
				TitleLocArgs: locArgs,
				BodyLocKey:   bodyLocKey,
				BodyLocArgs:  locArgs,
				ClickAction:  intent,
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Alert: &messaging.ApsAlert{
						TitleLocKey:  titleLocKey,
						TitleLocArgs: locArgs,
						LocKey:       bodyLocKey,
						LocArgs:      locArgs,
					},
					Category: intent,
				},
			},
		},
	}
}

type ChatMsgMessageConfig struct {
	FromID   string
	FromName string
	Msg      string
}

// ChatMsgMessage is the notification sent to a user when they receive a new
// chat message.
func ChatMsgMessage(config ChatMsgMessageConfig) messaging.Message {
	intent := "CHAT_MSG_INTENT"
	titleLocKey := "CHAT_MSG_NOTIFICATION_TITLE"
	locArgs := []string{config.FromName}

	return messaging.Message{
		Data: map[string]string{
			"type":         "chat-msg",
			"fromId":       config.FromID,
			"fromName":     config.FromName,
			"msgTruncated": config.Msg,
		},
		Android: &messaging.AndroidConfig{
			Notification: &messaging.AndroidNotification{
				TitleLocKey:  titleLocKey,
				TitleLocArgs: locArgs,
				ClickAction:  intent,
				Body:         config.Msg,
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Alert: &messaging.ApsAlert{
						TitleLocKey:  titleLocKey,
						TitleLocArgs: locArgs,
						Body:         config.Msg,
					},
					Category: intent,
				},
			},
		},
	}
}

type ReviewNotificationConfig struct {
	TaskID        string
	AssignmentID  string
	RequesterID   string
	RequesterName string
	Rating        int
	Comment       string
}

// ReviewNotification is the notification sent to the volunteer when the
// requester reviews the assignment.
func ReviewNotification(config ReviewNotificationConfig) messaging.Message {
	intent := "ASSIGNMENT_REVIEW_INTENT"
	titleLocKey := "ASSIGNMENT_REVIEW_NOTIFICATION_TITLE"
	bodyLocKey := "ASSIGNMENT_REVIEW_NOTIFICATION_BODY"
	locArgs := []string{
		config.RequesterName,
		fmt.Sprint(config.Rating),
		config.Comment,
	}

	return messaging.Message{
		Data: map[string]string{
			"type":             "assignment-review",
			"taskId":           config.TaskID,
			"assignmentId":     config.AssignmentID,
			"requesterId":      config.RequesterID,
			"rating":           fmt.Sprint(config.Rating),
			"commentTruncated": config.Comment,
		},
		Android: &messaging.AndroidConfig{
			Notification: &messaging.AndroidNotification{
				TitleLocKey:  titleLocKey,
				TitleLocArgs: locArgs,
				BodyLocKey:   bodyLocKey,
				BodyLocArgs:  locArgs,
				ClickAction:  intent,
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Alert: &messaging.ApsAlert{
						TitleLocKey:  titleLocKey,
						TitleLocArgs: locArgs,
						LocKey:       bodyLocKey,
						LocArgs:      locArgs,
					},
					Category: intent,
				},
			},
		},
	}
}
