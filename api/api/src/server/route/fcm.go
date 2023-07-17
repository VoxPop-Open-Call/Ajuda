package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func FCM(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	fcm := router.Group("/fcm", auth)
	{
		fcm.POST("/register", handle.WrapCreate(store.FCMTokens.Register))
	}
}
