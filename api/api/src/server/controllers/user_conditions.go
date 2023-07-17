package controllers

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type UserConditionController struct {
	db *gorm.DB
}

type ListUserConditionFilters struct {
	Pagination
	Sort
}

// Lists all user conditions.
//
//	@Summary	List all user conditions
//	@Tags		users
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		filters		query		ListUserConditionFilters	false	"Filters"
//	@Success	200			{array}		models.Condition
//	@Failure	400,401,500	{object}	middleware.ApiError
//	@Router		/user-conditions  [get]
func (c *UserConditionController) List(
	filters ListUserConditionFilters,
	_ *gin.Context,
) ([]models.Condition, error) {
	var conditions []models.Condition
	err := c.db.
		Model(&models.Condition{}).
		Limit(filters.Limit).
		Offset(filters.Offset).
		Order(filters.OrderBy.ToSnakeCase()).
		Find(&conditions).Error

	return conditions, err
}
