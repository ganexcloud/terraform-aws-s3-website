variable "name" {
  description = "Name of bucket"
}

variable "force_destroy" {
  description = "Delete all objects in bucket on destroy"
  default     = false
}

variable "versioned" {
  description = "Version the bucket"
  default     = false
}

variable "policy" {
  default     = ""
  description = "A valid bucket policy JSON document"
}

variable "tags" {
  type        = "map"
  description = "Additional Tags"
  default     = {}
}

variable "acl" {
  description = "ACL"
  default     = "private"
}
