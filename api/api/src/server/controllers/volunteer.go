package controllers

import (
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/query"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/httputil"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type VolunteerController struct {
	db  *gorm.DB
	acl authorizer
}

func (VolunteerController) Rules() []rule {
	return []rule{
		{models.User{}, []models.Volunteer{}, "list", func(ent, _ any) bool {
			return ent.(models.User).Admin || ent.(models.User).Elder != nil
		}},
	}
}

type ListVolunteersFilters struct {
	// Search by name or email (case-insensitive).
	Search       string         `form:"search"`
	TaskTypeCode string         `form:"taskTypeCode" example:"pharmacy"`
	Date         *types.Date    `form:"date" binding:"omitempty,datetime=2006-01-02" example:"2023-03-30"`
	TimeFrom     *types.TimeTZ  `form:"timeFrom" binding:"omitempty,datetime=15:04Z07:00" example:"12:00+02:00"`
	TimeTo       *types.TimeTZ  `form:"timeTo" binding:"omitempty,datetime=15:04Z07:00" example:"13:30+02:00"`
	WeekDays     []time.Weekday `form:"weekDays"`

	Requester models.User `json:"-" form:"-"`
}

// List retrieves the volunteers that match the given filters.
//
//	@Summary	List the volunteers that match the given filters
//	@Tags		volunteers
//	@Produce	json
//	@Security	OIDCToken
//	@Security	AuthHeader
//	@Param		filters			query		ListVolunteersFilters	false	"Filters"
//	@Success	200				{array}		models.User
//	@Failure	400,401,403,500	{object}	middleware.ApiError
//	@Router		/volunteers  [get]
func (c *VolunteerController) List(
	filters ListVolunteersFilters,
	ctx *gin.Context,
) ([]models.User, error) {
	user, err := tokenUser(ctx, c.db)
	if err != nil {
		return nil, err
	}

	if ok := c.acl.Authorize(user, "list", []models.Volunteer{}); !ok {
		return nil, httputil.NewErrorMsg(
			httputil.Forbidden,
			httputil.ForbiddenMessage,
		)
	}

	filters.Requester = user

	var volunteers []models.User
	if err := query.Users.Volunteers(filters.Search, c.db).
		Find(&volunteers).Error; err != nil {
		return nil, err
	}

	return filterVolunteers(volunteers, filters), nil
}

// volunteerFilterFuncs is an array of functions used to determine whether a
// volunteer matches a set of filters.
var volunteerFilterFuncs = [...](func(models.User, ListVolunteersFilters) bool){
	func(u models.User, f ListVolunteersFilters) bool {
		if f.Date == nil {
			return true
		}

		return u.Volunteer.IsAvailableAt(*f.Date, f.TimeFrom, f.TimeTo)
	},

	func(u models.User, f ListVolunteersFilters) bool {
		if f.WeekDays == nil || len(f.WeekDays) == 0 {
			return true
		}

		for _, wd := range f.WeekDays {
			if u.Volunteer.IsAvailableOn(wd, f.TimeFrom, f.TimeTo) {
				return true
			}
		}
		return false
	},

	func(u models.User, f ListVolunteersFilters) bool {
		return u.SpeaksAny(f.Requester.Languages)
	},
	func(u models.User, f ListVolunteersFilters) bool {
		return u.Location.Intersects(f.Requester.Location)
	},
}

// filterVolunteers applies the filterFuncs to a slice of volunteers and returns
// the entries that match.
func filterVolunteers(
	volunteers []models.User,
	params ListVolunteersFilters,
) []models.User {
	matchesAllFilters := func(u models.User) bool {
		for _, match := range volunteerFilterFuncs {
			if !match(u, params) {
				return false
			}
		}
		return true
	}

	result := make([]models.User, 0, len(volunteers))
	for _, user := range volunteers {
		if matchesAllFilters(user) {
			result = append(result, user)
		}
	}

	return result
}
