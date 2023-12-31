package models

import (
	"log"

	"bitbucket.org/mobinteg/ajuda-mais/resources"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Language struct {
	Code       string `json:"code" gorm:"primaryKey;type:varchar(5)"`
	Name       string `json:"name" gorm:"not null"`
	NativeName string `json:"nativeName" gorm:"not null"`
}

func (Language) Migrate(db *gorm.DB) error {
	for _, key := range resources.SupportedLanguages {
		lang := resources.Languages[key]

		if err := db.Clauses(clause.OnConflict{
			UpdateAll: true,
		}).Create(&Language{
			Code:       key,
			Name:       lang.Name,
			NativeName: lang.NativeName,
		}).Error; err != nil {
			log.Printf("error creating language %+v: %v", lang, err)
		}
	}

	return nil
}
