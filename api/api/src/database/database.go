package database

import (
	"fmt"
	"log"
	"time"

	"bitbucket.org/mobinteg/ajuda-mais/src/database/models"
	"bitbucket.org/mobinteg/ajuda-mais/src/database/seeders"
	"bitbucket.org/mobinteg/ajuda-mais/src/util/password"
	"github.com/google/uuid"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// Init connects to the database and runs auto-migrations.
// The admin user will be inserted if it's not present already.
func Init(dsn string) (*gorm.DB, error) {
	db, err := connect(dsn)
	if err != nil {
		return nil, err
	}

	migrate(
		db,
		&models.Language{},

		&models.User{},
		&models.Volunteer{},
		&models.Availability{},
		&models.Elder{},
		&models.EmergencyContact{},
		&models.PasswordResetCode{},
		&models.Condition{},

		&models.FCMToken{},

		&models.TaskType{},
		&models.Task{},
		&models.Assignment{},

		&models.ExternalContent{},

		&models.WorkerTask{},
	)

	return db, err
}

func connect(dsn string) (*gorm.DB, error) {
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	sqlDB, _ := db.DB()
	sqlDB.SetMaxIdleConns(5)
	sqlDB.SetMaxOpenConns(30)
	sqlDB.SetConnMaxLifetime(time.Hour)

	return db, nil
}

func migrate(db *gorm.DB, dst ...any) {
	for _, model := range dst {
		if err := db.AutoMigrate(model); err != nil {
			log.Printf("error auto-migrating %T: %v", model, err)
		} else if mModel, ok := model.(models.Migrator); ok {
			if err := mModel.Migrate(db); err != nil {
				log.Printf("error migrating %T: %v", model, err)
			}
		}
	}
}

// CreateAdminUser inserts a new admin user in the database with the given
// credentials, provided no other admin exists already.
func CreateAdminUser(email string, pw string, db *gorm.DB) error {
	if email == "" {
		return nil
	}

	if db.Limit(1).Find(&models.User{}, "admin = ?", true).RowsAffected > 0 {
		return nil
	}

	hash, err := password.Hash(pw)
	if err != nil {
		return err
	}

	uid, _ := uuid.NewRandom()

	return db.Create(&models.User{
		BaseModel: models.BaseModel{
			ID: uid,
		},
		Subject:        uid.String(),
		Email:          email,
		HashedPassword: hash,
		Admin:          true,
		Verified:       true,
	}).Error
}

// Seed inserts mock data into the database.
// Models that already have entries will be skipped.
func Seed(db *gorm.DB) {
	log.Println("Seeding database...")

	seedModel[models.User](seeders.User, db)
	seedModel[models.FCMToken](seeders.FCMToken, db)
	seedModel[models.Task](seeders.Task, db)

	log.Println("Done")
}

type seeder[T any] interface {
	Seed(*gorm.DB)
}

func seedModel[T any](seeder seeder[T], db *gorm.DB) {
	var model T
	if dbContains(&model, db) {
		fmt.Printf("Skipping %T, the table already contains entries.\n", model)
	} else {
		fmt.Printf("Seeding %-25T", model)
		seeder.Seed(db)
		fmt.Println("Done")
	}
}

func dbContains[T any](model *T, db *gorm.DB) bool {
	result := db.Limit(1).Find(model)
	return result.RowsAffected != 0
}
