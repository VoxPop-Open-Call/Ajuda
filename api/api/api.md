The server is divided into three base endpoints:

- `/api` for the CRUD operations
- `/docs` for API documentation
- `/dex` for OIDC authentication

### Authentication

Authentication requires an OIDC bearer token.
The issuer is `{domain}/dex`.

<details>

<summary>Details on user authentication</summary>

#### Discovery

`{domain}/dex/.well-known/openid-configuration`

#### Resource Owner Password Flow (username + password)

- [Resource Owner Password Flow with OIDC](https://auth0.com/docs/authenticate/login/oidc-conformant-authentication/oidc-adoption-rop-flow#oidc-conformant)

```
POST {domain}/dex/token
Content-Type: application/x-www-form-urlencoded
Body: {
    grant_type: "password",
    username: {email},
    password: {password},
    client_id: {client_id},
    client_secret: {client_secret},
    scope: "openid profile email offline_access",
}
```

#### Authorization Flow (3rd party)

- [Requesting an ID token from dex](https://dexidp.io/docs/using-dex/#requesting-an-id-token-from-dex)
- [Authorization Code Flow with OIDC](https://auth0.com/docs/authenticate/login/oidc-conformant-authentication/oidc-adoption-auth-code-flow#oidc-conformant)

```
GET {domain}/dex/auth(/{connector_id})?
    response_type=code
    &scope=openid profile email offline_access
    &client_id={client_id}
    &state={state}
    &redirect_uri={redirect_uri}
```

The optional `connector_id` will redirect directly to the 3rd party login,
instead of the intermediate page provided by Dex.

After the user completes the login with the third party, they will be
redirected to the `redirect_uri`, with the `state` provided above and a code:

```
HTTP/1.1 302 Found
Location: {redirect_uri}?
    code=SplxlOBeZQQYbYS6WxSbIA
    &state={state}
```

The `state` should be checked against the one provided in the auth request.

- [Prevent Attacks and Redirect Users with OAuth 2.0 State Parameters](https://auth0.com/docs/secure/attack-protection/state-parameters)

This `code` is then used to redeem the token:

- [Code exchange request](https://auth0.com/docs/authenticate/login/oidc-conformant-authentication/oidc-adoption-auth-code-flow#code-exchange-request-authorization-code-flow)

```
POST {domain}/dex/token
Content-Type: application/x-www-form-urlencoded
Body: {
  grant_type: "authorization_code",
  client_id: {client_id},
  client_secret: {client_secret},
  code: {code},
  redirect_uri: {redirect_uri},
}
```

#### Refresh token

- [Refresh Tokens with OIDC](https://auth0.com/docs/authenticate/login/oidc-conformant-authentication/oidc-adoption-refresh-tokens#oidc-conformant-token-endpoint-)

```
POST {domain}/dex/token
Content-Type: application/x-www-form-urlencoded
Body: {
  grant_type: "refresh_token",
  client_id: {client_id},
  client_secret: {client_secret},
  refresh_token: {refresh_token},
}
```

### User registration

#### Username + password

1. Create a new user with `[POST] {domain}/api/users`, providing the password.
2. Authenticate with Dex using the Resource Owner Password Flow, to obtain a
token.

#### With a third party account

1. Authenticate with Dex to the chosen third party, using the Authorization
Flow.
2. Create a new user with `[POST] {domain}/api/users`, providing the `sub`
field from the identification token received from step 1.

</details>

### FCM Notifications

Register FCM Tokens with `POST /fcm/register`, and the server will handle the
rest. Old or invalid tokens are deleted periodically. The apps should refresh
their tokens according to the FCM documentation.

Below are documented the FCM notifications that the server sends.
The apps should define the localization of the message title and body.

<details>

<summary>Details on FCM Notifications</summary>

<details>
<summary>**New assignment**</summary>

The server sends this notification to the volunteer when there is a new request
to perform a task.

``` go
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
```
</details>

<details>
<summary>**Task canceled**</summary>

The server sends this notification to the volunteer upon task cancellation, if
the assignment was previously accepted.

The apps should handle the intent and show the "Task Canceled" screen.

``` go
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
```
</details>

<details>
<summary>**Chat Message**</summary>

The server sends this notification to the target of a new chat message.

The apps should handle the intent accordingly.

``` go
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
```
</details>

<details>
<summary>**Assignment Review**</summary>

The server sends this notification to the volunteer when the requester reviews
the assignment.

The apps should handle the intent and show the "New rating received" screen.

``` go
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
```
</details>
</details>
