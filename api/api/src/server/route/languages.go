package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func Languages(
	router *gin.RouterGroup,
	store *controllers.Store,
) {
	router.GET("/languages", handle.List[
		controllers.ListLanguageFilters,
		models.Language,
	](store.Languages))
}
