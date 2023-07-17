package controllers

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type TaskTypeController struct {
	db *gorm.DB
}

type ListTaskTypeFilters struct {
	Pagination
	Sort
}

// Lists all task types.
//
//	@Summary	List all task types
//	@Tags		tasks
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		filters		query		ListTaskTypeFilters	false	"Filters"
//	@Success	200			{array}		models.TaskType
//	@Failure	400,401,500	{object}	middleware.ApiError
//	@Router		/task-types  [get]
func (c *TaskTypeController) List(
	filters ListTaskTypeFilters,
	_ *gin.Context,
) ([]models.TaskType, error) {
	var taskTypes []models.TaskType
	err := c.db.
		Model(&models.TaskType{}).
		Limit(filters.Limit).
		Offset(filters.Offset).
		Order(filters.OrderBy.ToSnakeCase()).
		Find(&taskTypes).Error

	return taskTypes, err
}
