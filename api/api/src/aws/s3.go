package aws

import (
	"context"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	signer "github.com/aws/aws-sdk-go-v2/aws/signer/v4"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

const (
	userFilesPrefix        = "user-files/"
	profilePicSuffix       = "/profilepic"
	presignedUrlExpiration = 10 * time.Minute
)

// S3 embeds both s3.Client and s3.PresignClient, and implements helper methods
// to work with objects in the user files bucket.
type S3 struct {
	*s3.Client
	*s3.PresignClient

	bucketName string
}

func newS3(config aws.Config, bucketName string) *S3 {
	client := s3.NewFromConfig(config)
	presignClient := s3.NewPresignClient(client)
	return &S3{
		Client:        client,
		PresignClient: presignClient,
		bucketName:    bucketName,
	}
}

func presignExpiration(opts *s3.PresignOptions) {
	opts.Expires = presignedUrlExpiration
}

// PresignGet generates a pre-signed request to retrieve an object from the
// user files bucket.
func (c *S3) PresignGet(key string) (*signer.PresignedHTTPRequest, error) {
	return c.PresignGetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: &c.bucketName,
		Key:    &key,
	}, presignExpiration)
}

// PresignPut generates a pre-signed request to put an object in the user files
// bucket.
func (c *S3) PresignPut(key string) (*signer.PresignedHTTPRequest, error) {
	return c.PresignPutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: &c.bucketName,
		Key:    &key,
	}, presignExpiration)
}

// PresignDelete generates a pre-signed request to delete an object from the
// user files bucket.
func (c *S3) PresignDelete(key string) (*signer.PresignedHTTPRequest, error) {
	return c.PresignDeleteObject(context.TODO(), &s3.DeleteObjectInput{
		Bucket: &c.bucketName,
		Key:    &key,
	}, presignExpiration)
}

func profilePicKey(userId string) string {
	return userFilesPrefix + userId + profilePicSuffix
}

func wrapProfilePicPresign(
	userId string,
	f func(string) (*signer.PresignedHTTPRequest, error),
) (url string, method string, err error) {
	req, err := f(profilePicKey(userId))
	if err != nil { // avoid nil pointer dereference
		return "", "", err
	}
	return req.URL, req.Method, err
}

func (c *S3) PresignGetProfilePicture(
	userId string,
) (url string, method string, err error) {
	return wrapProfilePicPresign(userId, c.PresignGet)
}

func (c *S3) PresignPutProfilePicture(
	userId string,
) (url string, method string, err error) {
	return wrapProfilePicPresign(userId, c.PresignPut)
}

func (c *S3) PresignDeleteProfilePicture(
	userId string,
) (url string, method string, err error) {
	return wrapProfilePicPresign(userId, c.PresignDelete)
}
