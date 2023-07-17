package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func Tasks(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	tasks := router.Group("/tasks", auth)
	{
		tasks.GET("", handle.List[
			controllers.ListTaskFilters,
			models.Task,
		](store.Tasks))

		tasks.GET("/:id", handle.Get[models.Task](store.Tasks))

		tasks.POST("", handle.Create[
			controllers.CreateTaskParams,
			models.Task,
		](store.Tasks))

		tasks.PUT("/:id", handle.Update[
			controllers.UpdateTaskParams,
			models.Task,
		](store.Tasks))

		tasks.PUT("/:id/cancel", handle.WrapAction(store.Tasks.Cancel))
	}
}
