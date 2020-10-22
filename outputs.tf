output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.name.id
}

output "cloudfront_id" {
  description = "The identifier for the cloudfront distribution"
  value       = aws_cloudfront_distribution.default.*.id
}

output "bucket_arn" {
  value       = aws_s3_bucket.name.arn
  description = "The ARN of the S3 Bucket project."
}
