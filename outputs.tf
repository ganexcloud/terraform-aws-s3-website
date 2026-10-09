output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.name.id
}

output "bucket_demain_name" {
  description = "S3 Bucket Domain Name"
  value       = aws_s3_bucket.name.bucket_domain_name
}

output "cloudfront_id" {
  description = "The identifier for the cloudfront distribution"
  value       = try(aws_cloudfront_distribution.default[0].id, "")
}

output "cloudfront_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = try(aws_cloudfront_distribution.default[0].arn, "")
}

output "cloudfront_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = try(aws_cloudfront_distribution.default[0].domain_name, "")
}

output "bucket_arn" {
  value       = aws_s3_bucket.name.arn
  description = "The ARN of the S3 Bucket project."
}

output "cloudfront_origin_access_control_id" {
  description = "ID of the Origin Access Control created by this module, or null when not created."
  value       = try(aws_cloudfront_origin_access_control.this[0].id, null)
}

output "cloudfront_cache_policy_id" {
  description = "ID of the cache policy created by this module, or null when not created."
  value       = try(aws_cloudfront_cache_policy.this[0].id, null)
}
