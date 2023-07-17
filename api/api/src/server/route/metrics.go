package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func Metrics(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	metrics := router.Group("/metrics", auth)
	{
		metrics.GET("/users", handle.WrapRetrieve(store.Metrics.Users))
		metrics.GET("/tasks", handle.WrapRetrieve(store.Metrics.Tasks))
	}
}
