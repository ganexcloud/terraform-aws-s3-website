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
