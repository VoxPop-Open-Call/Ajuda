package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type EmergencyContact struct {
	BaseModel   `json:"-"`
	Name        string `json:"name" gorm:"not null"`
	PhoneNumber string `json:"phoneNumber,omitempty" gorm:"type:varchar(30);not null"`

	// ElderID cannot be set as `not null` because of:
	// https://github.com/go-gorm/gorm/issues/4010
	//
	// The gist of it is that `Association.Replace` sets the foreign key to
	// null instead of actually deleting the records.
	ElderID uuid.UUID `json:"-"`
}

// Elder contains the profile fields exclusive to elders.
type Elder struct {
	ID uuid.UUID `json:"-" gorm:"primaryKey;type:uuid;default:gen_random_uuid()"`

	// EmergencyContacts are replaced when updating the elder.
	EmergencyContacts []EmergencyContact `json:"emergencyContacts,omitempty" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`

	UserID uuid.UUID `json:"-" gorm:"unique;not null"`
	User   User      `json:"-"`
}

func (Elder) Migrate(db *gorm.DB) error {
	if db.Migrator().HasConstraint(&Elder{}, "fk_elders_user") {
		return nil
	}

	return db.Exec(`
		ALTER TABLE elders
		ADD CONSTRAINT fk_elders_user
		FOREIGN KEY (user_id)
		REFERENCES users(id)
		ON UPDATE CASCADE ON DELETE CASCADE
	`).Error
}
