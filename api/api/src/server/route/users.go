package route

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/controllers"
	"bitbucket.org/mobinteg/ajuda-mais/src/server/handle"
	"github.com/gin-gonic/gin"
)

func Users(
	router *gin.RouterGroup,
	auth gin.HandlerFunc,
	store *controllers.Store,
) {
	users := router.Group("/users")
	{
		users.POST("", handle.Create[
			controllers.CreateUserParams,
			models.User,
		](store.Users))

		private := users.Group("", auth)
		{
			private.GET("", handle.List[
				controllers.ListUsersFilters,
				models.User,
			](store.Users))

			private.GET("/current", handle.WrapRetrieve(store.Users.GetCurrent))

			private.GET("/:id", handle.Get[controllers.UserResponse](store.Users))
			private.GET("/:id/picture-get-url", handle.WrapGet(store.Users.GetPictureURL))
			private.GET("/:id/picture-put-url", handle.WrapGet(store.Users.PutPictureURL))
			private.GET("/:id/picture-delete-url", handle.WrapGet(store.Users.DeletePictureURL))
			private.GET("/:id/rating", handle.WrapGet(store.Users.Rating))
			private.GET("/:id/reviews", handle.WrapGet(store.Users.Reviews))

			private.PUT("/:id", handle.Update[
				controllers.UpdateUserParams,
				controllers.UserResponse,
			](store.Users))

			private.DELETE("/:id", handle.Delete(store.Users))

			private.PUT("/:id/verify", handle.WrapAction(store.Users.Verify))
		}
	}
}
