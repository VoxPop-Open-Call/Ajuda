package controllers

import (
	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/httputil"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type MetricsController struct {
	db  *gorm.DB
	acl authorizer
}

// Rules returns the acl for the metrics controller.
func (MetricsController) Rules() []rule {
	return []rule{
		{models.User{}, query.UserMetrics{}, "get", func(ent, _ any) bool {
			return ent.(models.User).Admin
		}},
		{models.User{}, query.TaskMetrics{}, "get", func(ent, _ any) bool {
			return ent.(models.User).Admin
		}},
	}
}

// Retrieve user metrics.
//
//	@Summary	Retrieve user metrics
//	@Tags		metrics
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Success	200					{object}	query.UserMetrics
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/metrics/users [get]
func (c *MetricsController) Users(ctx *gin.Context) (query.UserMetrics, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return query.UserMetrics{}, err
	}

	if ok := c.acl.Authorize(
		user, "get", query.UserMetrics{},
	); !ok {
		return query.UserMetrics{}, httputil.NewErrorMsg(
			httputil.AdminAccessRequired,
			httputil.AdminRequiredMessage,
		)
	}

	return query.Metrics.Users(c.db)
}

// Retrieve task metrics.
//
//	@Summary	Retrieve task metrics
//	@Tags		metrics
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Success	200					{object}	query.TaskMetrics
//	@Failure	400,401,403,404,500	{object}	middleware.ApiError
//	@Router		/metrics/tasks [get]
func (c *MetricsController) Tasks(ctx *gin.Context) (query.TaskMetrics, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return query.TaskMetrics{}, err
	}

	if ok := c.acl.Authorize(
		user, "get", query.TaskMetrics{},
	); !ok {
		return query.TaskMetrics{}, httputil.NewErrorMsg(
			httputil.AdminAccessRequired,
			httputil.AdminRequiredMessage,
		)
	}

	return query.Metrics.Tasks(c.db)
}
