module "s3_website" {
  source = "../../"

  name                         = var.name
  website                      = {}
  block_public_acls            = true
  block_public_policy          = true
  ignore_public_acls           = true
  restrict_public_buckets      = true
  cloudfront_enabled           = true
  cloudfront_distribution_name = var.name
  cloudfront_aliases           = []
  route53_enabled              = false
  acm_certificate_arn          = var.acm_certificate_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "arn:aws:s3:::${var.name}/releases/*"
      Condition = { StringEquals = { "AWS:SourceArn" = module.s3_website.cloudfront_arn } }
    }]
  })

  cloudfront_use_forwarded_values = false
  cloudfront_cache_policy_id      = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # AWS CachingDisabled
  cloudfront_custom_origins = [{
    origin_id                = var.name
    domain_name              = "${var.name}.s3.us-east-1.amazonaws.com"
    origin_path              = "/releases"
    origin_access_control_id = var.origin_access_control_id
  }]
}

variable "name" {
  description = "Unique bucket name for this us-east-1 example."
  type        = string
  default     = "ganex-s3-website-existing-policies-example"
}

variable "origin_access_control_id" {
  description = "ID of an existing S3 OAC managed outside this module."
  type        = string
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN in us-east-1, supplied by the consumer."
  type        = string
}

output "created_origin_access_control_id" {
  description = "Null because the OAC is managed externally."
  value       = module.s3_website.cloudfront_origin_access_control_id
}

output "created_cache_policy_id" {
  description = "Null because the cache policy is managed by AWS."
  value       = module.s3_website.cloudfront_cache_policy_id
}
