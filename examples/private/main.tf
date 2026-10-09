locals {
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudFrontReleases"
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "arn:aws:s3:::${var.name}/releases/*"
      Condition = { StringEquals = { "AWS:SourceArn" = module.s3_website.cloudfront_arn } }
    }]
  })
}

module "s3_website" {
  source = "../../"

  name                         = var.name
  website                      = {}
  block_public_acls            = true
  block_public_policy          = true
  ignore_public_acls           = true
  restrict_public_buckets      = true
  policy                       = local.bucket_policy
  cloudfront_enabled           = true
  cloudfront_distribution_name = var.name
  cloudfront_aliases           = []
  route53_enabled              = false
  acm_certificate_arn          = var.acm_certificate_arn

  cloudfront_origin_access_control = { name = "${var.name}-oac" }
  cloudfront_cache_policy          = { name = "${var.name}-cache" }
  cloudfront_custom_origins = [{
    origin_id                        = var.name
    domain_name                      = "${var.name}.s3.us-east-1.amazonaws.com"
    origin_path                      = "/releases"
    use_module_origin_access_control = true
  }]
  cloudfront_ordered_cache_behavior = [{
    path_pattern            = "assets/*"
    target_origin_id        = var.name
    use_module_cache_policy = true
  }]
}

variable "name" {
  description = "Unique bucket and policy name for this us-east-1 example."
  type        = string
  default     = "ganex-s3-website-private-example"
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN in us-east-1, supplied by the consumer."
  type        = string
}

output "bucket_policy" {
  description = "Consumer-supplied policy granting this distribution access only to releases/*."
  value       = local.bucket_policy
}

output "cloudfront_arn" {
  description = "Distribution ARN used by the consumer's policy."
  value       = module.s3_website.cloudfront_arn
}

output "cloudfront_origin_access_control_id" {
  description = "OAC created by the module."
  value       = module.s3_website.cloudfront_origin_access_control_id
}

output "cloudfront_cache_policy_id" {
  description = "Cache policy created by the module."
  value       = module.s3_website.cloudfront_cache_policy_id
}
