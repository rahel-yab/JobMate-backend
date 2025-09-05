package dto

import "mime/multipart"

type CVUploadRequest struct {
	RawText string                `json:"rawText" form:"rawText"`
	File    *multipart.FileHeader `form:"file"`
}
