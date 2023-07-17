package models

import (
	"log"

	"bitbucket.org/mobinteg/ajuda-mais/resources"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/types"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/latlong"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type User struct {
	BaseModel
	Profile
	Subject        string `json:"subject" gorm:"unique;not null"`
	Email          string `json:"email" gorm:"unique;not null"`
	HashedPassword string `json:"-" gorm:"type:varchar(60);default:null"`
	Verified       bool   `json:"verified" gorm:"not null;default:false"`
	Admin          bool   `json:"-" gorm:"not null;default:false"`
}

type Profile struct {
	Name        string      `json:"name,omitempty" gorm:"default:null"`
	Birthday    *types.Date `json:"birthday,omitempty" gorm:"default:null"`
	Gender      string      `json:"gender,omitempty" gorm:"type:varchar(1);default:null" binding:"omitempty,oneof=M F X"`
	PhoneNumber string      `json:"phoneNumber,omitempty" gorm:"type:varchar(30);default:null"`
	FontScale   float32     `json:"fontScale,omitempty" gorm:"default:0"`
	Location    Location    `json:"-" gorm:"embedded"`

	// Languages are replaced when updating the user.
	Languages []Language `json:"languages,omitempty" gorm:"many2many:user_languages;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`

	// Conditions are replaced when updating the user.
	Conditions []Condition `json:"conditions,omitempty" gorm:"many2many:user_conditions;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`

	Volunteer *Volunteer `json:"volunteer,omitempty"`
	Elder     *Elder     `json:"elder,omitempty"`
}

// Speaks returns whether the user speaks the given language.
func (u User) Speaks(language Language) bool {
	for _, lang := range u.Languages {
		if lang.Code == language.Code {
			return true
		}
	}
	return false
}

// SpeaksAny returns whether the user speaks any of the given languages.
func (u User) SpeaksAny(languages []Language) bool {
	for _, lang := range languages {
		if u.Speaks(lang) {
			return true
		}
	}
	return false
}

type Location struct {
	Address string `json:"address"`

	// Lat is the latitude in decimal degrees of the approximate location of
	// the user.
	Lat float64 `json:"lat"`
	// Long is the longitude in decimal degrees of the approximate location of
	// the user.
	Long float64 `json:"long"`

	// Radius in kilometers of the circle, centered in the location
	// coordinates, inside which the volunteer can be assigned to perform
	// tasks.
	Radius float64 `json:"radius"`
}

// Intersects returns whether the location intersects another.
func (l Location) Intersects(other Location) bool {
	dist := latlong.Dist(
		latlong.Coords{Lat: l.Lat, Long: l.Long},
		latlong.Coords{Lat: other.Lat, Long: other.Long},
	)

	return dist <= l.Radius+other.Radius
}

type Condition struct {
	BaseModel
	Code string `json:"code" gorm:"unique;not null" example:"mobility-restrictions"`
}

func (Condition) Migrate(db *gorm.DB) error {
	for _, code := range resources.UserConditionCodes {
		if err := db.Clauses(clause.OnConflict{
			DoNothing: true,
		}).Create(&Condition{
			Code: code,
		}).Error; err != nil {
			log.Printf("error creating user condition %+v: %v", code, err)
		}
	}

	return nil
}
