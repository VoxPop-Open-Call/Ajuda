package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func ExternalContent(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	external := router.Group("/external", auth)
	{
		external.GET("", handle.List[
			controllers.ListExternalContentFilters,
			models.ExternalContent,
		](store.ExternalContent))

		external.PUT("/:id/approve", handle.WrapAction(store.ExternalContent.Approve))
		external.PUT("/:id/reject", handle.WrapAction(store.ExternalContent.Reject))

		external.GET("/subjects", handle.WrapList(store.ExternalContent.ListSubjects))
	}
}
