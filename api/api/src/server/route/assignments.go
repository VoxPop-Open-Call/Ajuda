package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func Assignments(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	assignments := router.Group("/assignments", auth)
	{
		assignments.GET("", handle.List[
			controllers.ListAssignmentFilters,
			models.Assignment,
		](store.Assignments))

		assignments.POST("", handle.Create[
			controllers.CreateAssignmentParams,
			models.Assignment,
		](store.Assignments))

		assignments.PUT("/:id/accept", handle.WrapAction(store.Assignments.Accept))
		assignments.PUT("/:id/reject", handle.WrapAction(store.Assignments.Reject))

		assignments.PUT("/:id/review", handle.WrapUpdate(store.Assignments.Review))
	}
}
