package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func UserConditions(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	userConditions := router.Group("/user-conditions", auth)
	{
		userConditions.GET("", handle.List[
			controllers.ListUserConditionFilters,
			models.Condition,
		](store.UserConditions))
	}
}
