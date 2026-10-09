variable "name" {
  description = "Name of s3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Delete all objects in bucket on destroy"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default     = {}
}

variable "website" {
  description = "Map containing static web-site hosting or redirect configuration."
  type        = map(string)
  default = {
    index_document = "index.html"
    error_document = "index.html"
  }
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "policy" {
  type        = string
  description = "A valid bucket policy JSON document"
  default     = ""
}

variable "replication_configuration" {
  description = "Map containing cross-region bucket replication configuration."
  type        = any
  default     = {}
}

variable "server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "ACL"
  type        = string
  default     = "private"
}

variable "grant" {
  description = "ACL policy grants to apply through aws_s3_bucket_acl. Supports either permission or permissions for compatibility with terraform-aws-s3-bucket style inputs."
  type        = any
  default     = []
}

variable "acl_owner" {
  description = "ACL owner configuration. If omitted, the current AWS canonical user ID is used."
  type        = map(string)
  default     = {}
}

variable "origin_path" {
  type        = string
  description = "An optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin. It must begin with a /. Do not add a / at the end of the path."
  default     = "/"
}

variable "cloudfront_enabled" {
  description = "Enable Cloudfront"
  type        = bool
  default     = false
}

variable "cloudfront_distribution_name" {
  description = "The name of the distribution."
  type        = string
  default     = ""
}

variable "cloudfront_comment" {
  description = "Cloudfront comments"
  type        = string
  default     = ""
}

variable "cloudfront_aliases" {
  description = "List of cloudfront_aliases"
  type        = list(string)
  default     = []
}

variable "cloudfront_price_class" {
  description = "Price class for this distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100`"
  type        = string
  default     = "PriceClass_All"
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  description = "Cloudfront TLS minimum protocol version"
  default     = "TLSv1.2_2021"
}

variable "cloudfront_default_ttl" {
  type        = number
  default     = 86400
  description = "Default amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "cloudfront_min_ttl" {
  type        = number
  default     = 0
  description = "Minimum amount of time that you want objects to stay in CloudFront caches"
}

variable "cloudfront_max_ttl" {
  type        = number
  default     = 31536000
  description = "Maximum amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "cloudfront_response_headers_policy_id" {
  description = "(Optional) The identifier for a response headers policy. If response_headers_policy is true the name of policy is used."
  type        = string
  default     = null
}

variable "cloudfront_response_headers_policy" {
  description = "(Optional) Provides a CloudFront response headers policy resource. A response headers policy contains information about a set of HTTP response headers and their values. After you create a response headers policy, you can use its ID to attach it to one or more cache behaviors in a CloudFront distribution. When it’s attached to a cache behavior, CloudFront adds the headers in the policy to every response that it sends for requests that match the cache behavior."
  type        = any
  default     = {}
}

variable "cloudfront_viewer_protocol_policy" {
  type        = string
  description = "allow-all, redirect-to-https"
  default     = "redirect-to-https"
}

variable "cloudfront_forward_cookies" {
  type        = string
  default     = "none"
  description = "Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none'"
}

variable "cloudfront_forward_header_values" {
  type        = list(string)
  description = "A list of whitelisted header values to forward to the origin"
  default     = []
}

variable "cloudfront_forward_query_string" {
  type        = bool
  default     = false
  description = "Forward query strings to the origin that is associated with this cache behavior"
}

variable "cloudfront_trusted_signers" {
  type        = list(string)
  default     = []
  description = "The AWS accounts, if any, that you want to allow to create signed URLs for private content. 'self' is acceptable."
}

variable "cloudfront_compress" {
  type        = bool
  default     = true
  description = "Enable automatic compression for eligible content. Cache-policy encoding flags control Gzip/Brotli support."
}

variable "cloudfront_allowed_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront"
}

variable "cloudfront_cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD)"
}

variable "cloudfront_index_document" {
  type        = string
  default     = "index.html"
  description = "Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders"
}

variable "cloudfront_default_target_origin_id" {
  type        = string
  default     = null
  description = "The value of ID for the origin that you want CloudFront to route requests to the default cache behavior"
}

variable "cloudfront_ordered_cache_behavior" {
  type        = any
  default     = []
  description = "(Optional) - An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
}

variable "cloudfront_custom_error_response" {
  type = list(object({
    error_caching_min_ttl = number
    error_code            = number
    response_code         = number
    response_page_path    = string
  }))
  description = "List of one or more custom error response element maps"
  default     = []
}

variable "cloudfront_custom_origins" {
  type        = any
  default     = []
  description = "One or more custom origins for this distribution (multiples allowed). Each origin may set origin_access_control_id for an existing CloudFront Origin Access Control. See documentation for configuration options description https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments"
}

variable "cloudfront_origin_group" {
  description = "One or more origin_group for this distribution (multiples allowed)."
  type        = any
  default     = {}
}

variable "cloudfront_cache_policy_id" {
  description = "(Optional) - The unique identifier of the cache policy that is attached to the cache behavior."
  type        = string
  default     = ""
}

variable "cloudfront_origin_access_control" {
  description = "Optional S3 Origin Access Control to create. Used by the automatic bucket origin; explicit origins opt in with use_module_origin_access_control. Bucket permissions remain the consumer's responsibility."
  type = object({
    name             = string
    description      = optional(string)
    signing_behavior = optional(string, "always")
    signing_protocol = optional(string, "sigv4")
  })
  default = null

  validation {
    condition = var.cloudfront_origin_access_control == null ? true : (
      try(length(trimspace(var.cloudfront_origin_access_control.name)) > 0, false) &&
      contains(["always", "never", "no-override"], var.cloudfront_origin_access_control.signing_behavior) &&
      var.cloudfront_origin_access_control.signing_protocol == "sigv4"
    )
    error_message = "OAC requires a non-empty name, signing_behavior always/never/no-override, and signing_protocol sigv4."
  }
}

variable "cloudfront_cache_policy" {
  description = "Optional cache policy to create and attach to the default behavior. Ordered behaviors opt in with use_module_cache_policy. Existing policy IDs remain supported."
  type = object({
    name        = string
    comment     = optional(string)
    min_ttl     = optional(number, 0)
    default_ttl = optional(number, 86400)
    max_ttl     = optional(number, 31536000)
    parameters_in_cache_key_and_forwarded_to_origin = optional(object({
      enable_accept_encoding_brotli = optional(bool, true)
      enable_accept_encoding_gzip   = optional(bool, true)
      cookies_config = optional(object({
        cookie_behavior = optional(string, "none")
        items           = optional(set(string), [])
      }), {})
      headers_config = optional(object({
        header_behavior = optional(string, "none")
        items           = optional(set(string), [])
      }), {})
      query_strings_config = optional(object({
        query_string_behavior = optional(string, "none")
        items                 = optional(set(string), [])
      }), {})
    }), {})
  })
  default = null

  validation {
    condition = var.cloudfront_cache_policy == null ? true : (
      try(length(trimspace(var.cloudfront_cache_policy.name)) > 0, false) &&
      alltrue([for ttl in [var.cloudfront_cache_policy.min_ttl, var.cloudfront_cache_policy.default_ttl, var.cloudfront_cache_policy.max_ttl] : ttl >= 0 && floor(ttl) == ttl]) &&
      var.cloudfront_cache_policy.min_ttl <= var.cloudfront_cache_policy.default_ttl &&
      var.cloudfront_cache_policy.default_ttl <= var.cloudfront_cache_policy.max_ttl
    )
    error_message = "Cache policy requires a non-empty name and integer TTLs satisfying 0 <= min_ttl <= default_ttl <= max_ttl."
  }

  validation {
    condition = var.cloudfront_cache_policy == null ? true : (
      contains(["none", "whitelist", "allExcept", "all"], var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.cookies_config.cookie_behavior) &&
      contains(["none", "whitelist"], var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.headers_config.header_behavior) &&
      contains(["none", "whitelist", "allExcept", "all"], var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.query_strings_config.query_string_behavior) &&
      alltrue([
        for config in [
          { behavior = var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.cookies_config.cookie_behavior, items = var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.cookies_config.items },
          { behavior = var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.headers_config.header_behavior, items = var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.headers_config.items },
          { behavior = var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.query_strings_config.query_string_behavior, items = var.cloudfront_cache_policy.parameters_in_cache_key_and_forwarded_to_origin.query_strings_config.items }
        ] : contains(["whitelist", "allExcept"], config.behavior) ? length(config.items) > 0 && alltrue([for item in config.items : try(length(trimspace(item)) > 0, false)]) : length(config.items) == 0
      ])
    )
    error_message = "Use supported cache-key behaviors; whitelist/allExcept require non-empty items, while none/all require no items."
  }
}

variable "cloudfront_use_forwarded_values" {
  description = "Enable forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers (maximum one)."
  type        = bool
  default     = true
}

variable "cloudfront_create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = false
}

variable "cloudfront_origin_access_identities" {
  description = "Map of CloudFront origin access identities (value as a comment)"
  type        = map(string)
  default     = {}
}

variable "cloudfront_lambda_function_association" {
  description = "(Optional) - A config block that triggers a lambda function with specific actions (maximum 4)."
  type        = any
  default     = {}
}

variable "cloudfront_function_association" {
  description = "(Optional) - A config block that triggers a cloudfront function with specific actions (maximum 2)."
  type        = any
  default     = {}
}

variable "cloudfront_http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3, and http3. The default is http2and3."
  type        = string
  default     = "http2and3"
}

variable "route53_enabled" {
  description = "Whether to create Route 53 DNS records for CloudFront aliases. Disabled by default."
  type        = bool
  default     = false
}

variable "route53_parent_zone_id" {
  description = "ID of the hosted zone to contain this record  (or specify `parent_zone_name`)"
  type        = string
  default     = ""
}

variable "route53_parent_zone_name" {
  description = "Name of the hosted zone to contain this record (or specify `parent_zone_id`)"
  type        = string
  default     = ""
}

variable "route53_evaluate_target_health" {
  description = "Set to true if you want Route 53 to determine whether to respond to DNS queries"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ARN of Certificate"
  type        = string
  default     = ""
}

variable "lambda_notifications" {
  description = "Map of S3 bucket notifications to Lambda function"
  type        = any
  default     = {}
}

variable "sqs_notifications" {
  description = "Map of S3 bucket notifications to SQS queue"
  type        = any
  default     = {}
}

variable "sns_notifications" {
  description = "Map of S3 bucket notifications to SNS topic"
  type        = any
  default     = {}
}

variable "s3_cors_rule" {
  description = "(Optional) List of maps containing rules for Cross-Origin Resource Sharing."
  type        = any
  default     = []
}

variable "logging_target_bucket" {
  description = "(Optional) Name of the bucket where S3 server access logs will be delivered."
  type        = string
  default     = ""
}

variable "logging_target_prefix" {
  description = "(Optional) Prefix for S3 server access log objects."
  type        = string
  default     = ""
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object Ownership has three settings that you can use to control ownership of objects uploaded to your bucket and to disable (BucketOwnerEnforced) or enable ACLs (BucketOwnerPreferred or ObjectWriter)"
  type        = string
  default     = "BucketOwnerEnforced"
}
