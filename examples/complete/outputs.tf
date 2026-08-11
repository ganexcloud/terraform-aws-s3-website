output "bucket_name" {
  description = "Created S3 bucket name."
  value       = module.s3_website.bucket_name
}

output "cloudfront_id" {
  description = "Created CloudFront distribution ID, or an empty string when disabled."
  value       = module.s3_website.cloudfront_id
}
