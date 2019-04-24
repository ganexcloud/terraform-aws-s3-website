variable "name" {
  description = "Name of s3 bucket"
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

variable "index_document" {
  description = "Configure index"
  default     = "index.html"
}

variable "error_document" {
  description = "Configure error document"
  default     = "404.html"
}

variable "cloudfront_enabled" {
  description = "Enable Cloudfront"
  default     = "false"
}

variable "cloudfront_distribution_name" {
  description = "The name of the distribution."
  type        = "string"
  default     = ""
}

variable "cloudfront_comment" {
  description = "Cloudfront comments"
  type        = "string"
  default     = ""
}

variable "cloudfront_aliases" {
  type        = "list"
  description = "List of cloudfront_aliases"
  default     = [""]
}

variable "cloudfront_viewer_protocol_policy" {
  description = "Protocol Policy"
  default     = ""
}

variable "route53_enabled" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

variable "route53_parent_zone_id" {
  default     = ""
  description = "ID of the hosted zone to contain this record  (or specify `parent_zone_name`)"
}

variable "route53_parent_zone_name" {
  default     = ""
  description = "Name of the hosted zone to contain this record (or specify `parent_zone_id`)"
}

variable "route53_evaluate_target_health" {
  default     = "false"
  description = "Set to true if you want Route 53 to determine whether to respond to DNS queries"
}

variable "acm_certificate_arn" {
  description = "ARN of Certificate"
  default     = ""
}

variable "custom_error_response" {
  description = "(Optional) - List of one or more custom error response element maps"
  type        = "list"
  default     = []
}
