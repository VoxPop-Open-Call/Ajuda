package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func TaskTypes(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	taskTypes := router.Group("/task-types", auth)
	{
		taskTypes.GET("", handle.List[
			controllers.ListTaskTypeFilters,
			models.TaskType,
		](store.TaskTypes))
	}
}
