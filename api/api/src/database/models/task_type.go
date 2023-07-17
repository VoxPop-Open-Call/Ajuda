package models

import (
	"log"

	"bitbucket.org/mobinteg/ajuda-mais/resources"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type TaskType struct {
	BaseModel
	Code string `json:"code" gorm:"unique;not null" example:"pharmacy"`
}

func (TaskType) Migrate(db *gorm.DB) error {
	for _, code := range resources.TaskTypeCodes {
		if err := db.Clauses(clause.OnConflict{
			DoNothing: true,
		}).Create(&TaskType{
			Code: code,
		}).Error; err != nil {
			log.Printf("error creating task type %+v: %v", code, err)
		}
	}

	return nil
}
