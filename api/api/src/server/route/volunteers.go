package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func Volunteers(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	volunteers := router.Group("/volunteers", auth)
	{
		volunteers.GET("", handle.List[
			controllers.ListVolunteersFilters,
			models.User,
		](store.Volunteers))
	}
}
