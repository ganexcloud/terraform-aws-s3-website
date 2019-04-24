output "bucket_name" {
  description = "S3 Bucket Name"
  value       = "${aws_s3_bucket.name.id}"
}

output "bucket_arn" {
  value       = "${aws_s3_bucket.name.arn}"
  description = "The ARN of the S3 Bucket project."
}
