locals {
  cloudfront_create_origin_access_identity = var.cloudfront_create_origin_access_identity && length(keys(var.cloudfront_origin_access_identities)) > 0
}
