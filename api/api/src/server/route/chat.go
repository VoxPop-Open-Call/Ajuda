package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func Chat(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	chat := router.Group("/chat")
	chat.GET("/ws", store.Chat.Subscribe)

	private := chat.Use(auth)
	{
		private.GET("/token", handle.WrapRetrieve(store.Chat.GenerateToken))
		private.GET("", handle.WrapList(store.Chat.ListMessages))
		private.POST("", handle.WrapCreate(store.Chat.PostMessage))
	}
}
