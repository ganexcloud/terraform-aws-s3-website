mock_provider "aws" {
  override_during = plan
  mock_resource "aws_s3_bucket" {
    defaults = {
      id                          = "test-site"
      arn                         = "arn:aws:s3:::test-site"
      bucket_domain_name          = "test-site.s3.amazonaws.com"
      bucket_regional_domain_name = "test-site.s3.us-east-1.amazonaws.com"
    }
  }
  mock_resource "aws_cloudfront_origin_access_control" {
    defaults = { id = "EINTERNALOAC" }
  }
  mock_resource "aws_cloudfront_cache_policy" {
    defaults = { id = "11111111-1111-1111-1111-111111111111" }
  }
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
}

variables {
  name                         = "test-site"
  cloudfront_enabled           = true
  cloudfront_distribution_name = "test-origin"
  acm_certificate_arn          = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
}

run "legacy_bucket_and_forwarding_defaults" {
  command = plan
  assert {
    condition     = length(aws_cloudfront_origin_access_control.this) == 0 && length(aws_cloudfront_cache_policy.this) == 0 && output.cloudfront_origin_access_control_id == null && output.cloudfront_cache_policy_id == null
    error_message = "New resources and outputs must remain absent by default."
  }
  assert {
    condition     = one(aws_cloudfront_distribution.default[0].origin).domain_name == "test-site.s3.amazonaws.com" && length(aws_cloudfront_distribution.default[0].default_cache_behavior[0].forwarded_values) == 1 && aws_cloudfront_distribution.default[0].default_cache_behavior[0].default_ttl == 86400
    error_message = "Legacy origin and forwarding must be preserved."
  }
  assert {
    condition     = aws_s3_bucket.name.bucket == "test-site" && length(aws_s3_bucket_website_configuration.this) == 1 && !aws_s3_bucket_public_access_block.this.block_public_policy && one(data.aws_iam_policy_document.origin_website.statement).resources == toset(["arn:aws:s3:::test-site/*"])
    error_message = "Existing bucket, website, public access and policy configuration must remain unchanged."
  }
}

run "modern_http_and_explicit_dns_defaults" {
  command = plan
  variables { cloudfront_aliases = ["site.example.com"] }
  assert {
    condition     = length(data.aws_route53_zone.default) == 0 && length(aws_route53_record.default) == 0 && aws_cloudfront_distribution.default[0].http_version == "http2and3" && aws_cloudfront_distribution.default[0].viewer_certificate[0].minimum_protocol_version == "TLSv1.2_2021" && aws_cloudfront_distribution.default[0].default_cache_behavior[0].compress
    error_message = "Modern HTTP/TLS/compression defaults must not implicitly create DNS records or hosted-zone lookups for aliases."
  }
}

run "default_certificate_without_aliases" {
  command = plan
  variables { acm_certificate_arn = "" }
  assert {
    condition     = length(aws_cloudfront_distribution.default[0].aliases) == 0 && aws_cloudfront_distribution.default[0].viewer_certificate[0].cloudfront_default_certificate && aws_cloudfront_distribution.default[0].viewer_certificate[0].minimum_protocol_version == "TLSv1"
    error_message = "Without ACM or aliases, use the default CloudFront certificate and its supported TLS policy."
  }
}

run "explicit_legacy_dns_tls_and_compression" {
  command = plan
  variables {
    cloudfront_aliases                  = ["site.example.com"]
    route53_enabled                     = true
    route53_parent_zone_id              = "Z123456789EXAMPLE"
    cloudfront_minimum_protocol_version = "TLSv1.1_2016"
    cloudfront_compress                 = false
    cloudfront_cache_policy = {
      name = "uncompressed-cache"
      parameters_in_cache_key_and_forwarded_to_origin = {
        enable_accept_encoding_gzip   = false
        enable_accept_encoding_brotli = false
      }
    }
  }
  assert {
    condition     = length(data.aws_route53_zone.default) == 1 && length(aws_route53_record.default) == 1 && aws_cloudfront_distribution.default[0].viewer_certificate[0].minimum_protocol_version == "TLSv1.1_2016" && !aws_cloudfront_distribution.default[0].default_cache_behavior[0].compress && !aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].enable_accept_encoding_gzip && !aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].enable_accept_encoding_brotli
    error_message = "Explicit DNS, legacy TLS and compression opt-outs must continue to work."
  }
}

run "internal_default_origin_and_cache" {
  command = plan
  variables {
    cloudfront_origin_access_control = { name = "test-oac" }
    cloudfront_cache_policy          = { name = "test-cache" }
  }
  assert {
    condition     = one(aws_cloudfront_distribution.default[0].origin).origin_access_control_id == output.cloudfront_origin_access_control_id && one(aws_cloudfront_distribution.default[0].origin).domain_name == "test-site.s3.us-east-1.amazonaws.com"
    error_message = "The automatic origin must use the created OAC and regional endpoint."
  }
  assert {
    condition     = aws_cloudfront_origin_access_control.this[0].origin_access_control_origin_type == "s3" && aws_cloudfront_origin_access_control.this[0].signing_behavior == "always" && aws_cloudfront_origin_access_control.this[0].signing_protocol == "sigv4"
    error_message = "OAC defaults must use S3 and always/sigv4 signing."
  }
  assert {
    condition     = aws_cloudfront_distribution.default[0].default_cache_behavior[0].cache_policy_id == output.cloudfront_cache_policy_id && length(aws_cloudfront_distribution.default[0].default_cache_behavior[0].forwarded_values) == 0
    error_message = "The default behavior must select the created policy and omit legacy forwarding."
  }
  assert {
    condition     = aws_cloudfront_cache_policy.this[0].min_ttl == 0 && aws_cloudfront_cache_policy.this[0].default_ttl == 86400 && aws_cloudfront_cache_policy.this[0].max_ttl == 31536000 && aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].cookies_config[0].cookie_behavior == "none" && aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].headers_config[0].header_behavior == "none" && aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].query_strings_config[0].query_string_behavior == "none" && aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].enable_accept_encoding_gzip && aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].enable_accept_encoding_brotli
    error_message = "Cache defaults must use the documented TTLs, omit application-specific cache keys and enable encoding negotiation."
  }
}

run "internal_selectors_and_custom_cache_key" {
  command = plan
  variables {
    cloudfront_origin_access_control = { name = "test-oac" }
    cloudfront_custom_origins = [
      { origin_id = "test-origin", domain_name = "test-site.s3.us-east-1.amazonaws.com", origin_path = "/releases", use_module_origin_access_control = true },
      { origin_id = "other-origin", domain_name = "other.s3.us-east-1.amazonaws.com", origin_access_control_id = "EEXTERNALOAC" }
    ]
    cloudfront_cache_policy = {
      name        = "test-cache"
      min_ttl     = 0
      default_ttl = 60
      max_ttl     = 3600
      parameters_in_cache_key_and_forwarded_to_origin = {
        enable_accept_encoding_gzip   = true
        enable_accept_encoding_brotli = true
        cookies_config                = { cookie_behavior = "whitelist", items = ["session"] }
        headers_config                = { header_behavior = "whitelist", items = ["Origin"] }
        query_strings_config          = { query_string_behavior = "allExcept", items = ["tracking"] }
      }
    }
    cloudfront_ordered_cache_behavior = [
      { path_pattern = "assets/*", target_origin_id = "test-origin", use_module_cache_policy = true, "true" = true },
      { path_pattern = "other/*", target_origin_id = "other-origin", cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" }
    ]
  }
  assert {
    condition     = one([for origin in aws_cloudfront_distribution.default[0].origin : origin if origin.origin_id == "test-origin"]).origin_access_control_id == "EINTERNALOAC" && one([for origin in aws_cloudfront_distribution.default[0].origin : origin if origin.origin_id == "test-origin"]).origin_path == "/releases" && one([for origin in aws_cloudfront_distribution.default[0].origin : origin if origin.origin_id == "other-origin"]).origin_access_control_id == "EEXTERNALOAC"
    error_message = "Explicit origins must select only their requested internal or external OAC."
  }
  assert {
    condition     = aws_cloudfront_distribution.default[0].ordered_cache_behavior[0].cache_policy_id == output.cloudfront_cache_policy_id && length(aws_cloudfront_distribution.default[0].ordered_cache_behavior[0].forwarded_values) == 0 && aws_cloudfront_distribution.default[0].ordered_cache_behavior[1].cache_policy_id == "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    error_message = "Ordered behaviors must select their requested policies without legacy forwarding."
  }
  assert {
    condition     = aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].cookies_config[0].cookies[0].items == toset(["session"]) && aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].headers_config[0].headers[0].items == toset(["Origin"]) && aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].query_strings_config[0].query_strings[0].items == toset(["tracking"]) && aws_cloudfront_cache_policy.this[0].parameters_in_cache_key_and_forwarded_to_origin[0].enable_accept_encoding_gzip
    error_message = "Configured cache-key lists and compression must reach the created policy."
  }
}

run "external_resources" {
  command = plan
  variables {
    cloudfront_use_forwarded_values = false
    cloudfront_cache_policy_id      = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cloudfront_custom_origins       = [{ origin_id = "test-origin", domain_name = "test-site.s3.us-east-1.amazonaws.com", origin_access_control_id = "EEXTERNALOAC" }]
  }
  assert {
    condition     = length(aws_cloudfront_origin_access_control.this) == 0 && length(aws_cloudfront_cache_policy.this) == 0 && one(aws_cloudfront_distribution.default[0].origin).origin_access_control_id == "EEXTERNALOAC" && aws_cloudfront_distribution.default[0].default_cache_behavior[0].cache_policy_id == var.cloudfront_cache_policy_id
    error_message = "Reusing existing resources must not create new OACs or policies."
  }
}

run "cloudfront_disabled" {
  command = plan
  variables { cloudfront_enabled = false }
  assert {
    condition     = length(aws_cloudfront_distribution.default) == 0 && output.cloudfront_id == "" && output.cloudfront_arn == "" && output.cloudfront_domain_name == "" && output.cloudfront_cache_policy_id == null && output.cloudfront_origin_access_control_id == null
    error_message = "Disabled CloudFront must retain safe outputs."
  }
}

run "standalone_optional_resources" {
  command = plan
  variables {
    cloudfront_enabled               = false
    cloudfront_origin_access_control = { name = "standalone-oac" }
    cloudfront_cache_policy          = { name = "standalone-cache" }
  }
  assert {
    condition     = length(aws_cloudfront_distribution.default) == 0 && output.cloudfront_origin_access_control_id == "EINTERNALOAC" && output.cloudfront_cache_policy_id == "11111111-1111-1111-1111-111111111111"
    error_message = "Explicitly requested policies can be created without a distribution."
  }
}

run "reject_invalid_ttls" {
  command = plan
  variables { cloudfront_cache_policy = { name = "bad-cache", min_ttl = 100, default_ttl = 10 } }
  expect_failures = [var.cloudfront_cache_policy]
}

run "reject_fractional_ttls" {
  command = plan
  variables { cloudfront_cache_policy = { name = "bad-cache", min_ttl = 0.5 } }
  expect_failures = [var.cloudfront_cache_policy]
}

run "reject_empty_whitelist" {
  command = plan
  variables {
    cloudfront_cache_policy = {
      name                                            = "bad-cache"
      parameters_in_cache_key_and_forwarded_to_origin = { headers_config = { header_behavior = "whitelist" } }
    }
  }
  expect_failures = [var.cloudfront_cache_policy]
}

run "reject_invalid_signing" {
  command = plan
  variables { cloudfront_origin_access_control = { name = "bad-oac", signing_protocol = "invalid" } }
  expect_failures = [var.cloudfront_origin_access_control]
}

run "reject_null_oac_name" {
  command = plan
  variables { cloudfront_origin_access_control = { name = null } }
  expect_failures = [var.cloudfront_origin_access_control]
}

run "reject_null_cache_name" {
  command = plan
  variables { cloudfront_cache_policy = { name = null } }
  expect_failures = [var.cloudfront_cache_policy]
}

run "reject_null_cache_key_item" {
  command = plan
  variables {
    cloudfront_cache_policy = { name = "bad-cache", parameters_in_cache_key_and_forwarded_to_origin = { headers_config = { header_behavior = "whitelist", items = [null] } } }
  }
  expect_failures = [var.cloudfront_cache_policy]
}

run "reject_default_cache_conflict" {
  command = plan
  variables {
    cloudfront_cache_policy    = { name = "internal-cache" }
    cloudfront_cache_policy_id = "external-cache"
  }
  expect_failures = [aws_cloudfront_cache_policy.this]
}

run "reject_external_cache_forwarding" {
  command = plan
  variables { cloudfront_cache_policy_id = "external-cache" }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "reject_missing_oac" {
  command = plan
  variables { cloudfront_custom_origins = [{ origin_id = "test-origin", domain_name = "test-site.s3.us-east-1.amazonaws.com", use_module_origin_access_control = true }] }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "reject_oac_selection_conflict" {
  command = plan
  variables {
    cloudfront_origin_access_control = { name = "test-oac" }
    cloudfront_custom_origins        = [{ origin_id = "test-origin", domain_name = "test-site.s3.us-east-1.amazonaws.com", use_module_origin_access_control = true, origin_access_control_id = "EEXTERNALOAC" }]
  }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "reject_oac_with_oai" {
  command = plan
  variables {
    cloudfront_custom_origins = [{ origin_id = "test-origin", domain_name = "test-site.s3.us-east-1.amazonaws.com", origin_access_control_id = "EEXTERNALOAC", s3_origin_config = { cloudfront_access_identity_path = "origin-access-identity/cloudfront/EEXTERNALOAI" } }]
  }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "reject_oac_with_custom_origin" {
  command = plan
  variables {
    cloudfront_origin_access_control = { name = "test-oac" }
    cloudfront_custom_origins        = [{ origin_id = "test-origin", domain_name = "example.com", use_module_origin_access_control = true, custom_origin_config = { origin_protocol_policy = "https-only" } }]
  }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "preserve_external_oac_on_lambda_origin" {
  command = plan
  variables {
    cloudfront_custom_origins = [{ origin_id = "test-origin", domain_name = "example.lambda-url.us-east-1.on.aws", origin_access_control_id = "EEXTERNALLAMBDAOAC", custom_origin_config = { origin_protocol_policy = "https-only" } }]
  }
  assert {
    condition     = one(aws_cloudfront_distribution.default[0].origin).origin_access_control_id == "EEXTERNALLAMBDAOAC" && one(aws_cloudfront_distribution.default[0].origin).custom_origin_config[0].origin_protocol_policy == "https-only" && length(aws_cloudfront_origin_access_control.this) == 0
    error_message = "Existing external OACs must remain usable on supported custom origins such as Lambda URLs."
  }
}

run "reject_missing_ordered_cache" {
  command = plan
  variables { cloudfront_ordered_cache_behavior = [{ path_pattern = "assets/*", target_origin_id = "test-origin", use_module_cache_policy = true }] }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "reject_ordered_cache_selection_conflict" {
  command = plan
  variables {
    cloudfront_cache_policy           = { name = "test-cache" }
    cloudfront_ordered_cache_behavior = [{ path_pattern = "assets/*", target_origin_id = "test-origin", use_module_cache_policy = true, cache_policy_id = "external-cache" }]
  }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "reject_ordered_external_forwarding" {
  command = plan
  variables { cloudfront_ordered_cache_behavior = [{ path_pattern = "assets/*", target_origin_id = "test-origin", cache_policy_id = "external-cache", "true" = true }] }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "reject_invalid_selector" {
  command = plan
  variables { cloudfront_custom_origins = [{ origin_id = "test-origin", domain_name = "test-site.s3.us-east-1.amazonaws.com", use_module_origin_access_control = "yes" }] }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "reject_invalid_ordered_selector" {
  command = plan
  variables { cloudfront_ordered_cache_behavior = [{ path_pattern = "assets/*", target_origin_id = "test-origin", use_module_cache_policy = "yes", cache_policy_id = "external-cache" }] }
  expect_failures = [aws_cloudfront_distribution.default]
}

run "legacy_oai_origin" {
  command = plan
  variables {
    cloudfront_custom_origins = [{ origin_id = "test-origin", domain_name = "test-site.s3.us-east-1.amazonaws.com", s3_origin_config = { cloudfront_access_identity_path = "origin-access-identity/cloudfront/EEXTERNALOAI" } }]
  }
  assert {
    condition     = one(aws_cloudfront_distribution.default[0].origin).s3_origin_config[0].origin_access_identity == "origin-access-identity/cloudfront/EEXTERNALOAI" && length(aws_cloudfront_origin_access_control.this) == 0
    error_message = "Existing OAI origins must remain supported without an OAC."
  }
}

run "oac_with_empty_oai_path" {
  command = plan
  variables {
    cloudfront_origin_access_control = { name = "test-oac" }
    cloudfront_custom_origins        = [{ origin_id = "test-origin", domain_name = "test-site.s3.us-east-1.amazonaws.com", use_module_origin_access_control = true, s3_origin_config = { cloudfront_access_identity_path = "" } }]
  }
  assert {
    condition     = one(aws_cloudfront_distribution.default[0].origin).origin_access_control_id == "EINTERNALOAC" && one(aws_cloudfront_distribution.default[0].origin).s3_origin_config[0].origin_access_identity == ""
    error_message = "An empty OAI path is compatible with OAC."
  }
}

run "reject_unsupported_cache_key_behavior" {
  command = plan
  variables {
    cloudfront_cache_policy = { name = "bad-cache", parameters_in_cache_key_and_forwarded_to_origin = { headers_config = { header_behavior = "all" } } }
  }
  expect_failures = [var.cloudfront_cache_policy]
}

run "preserve_consumer_policy_and_private_flags" {
  command = plan
  variables {
    cloudfront_origin_access_control = { name = "test-oac" }
    website                          = {}
    block_public_acls                = true
    block_public_policy              = true
    ignore_public_acls               = true
    restrict_public_buckets          = true
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::test-site/releases/*"
        Condition = { StringEquals = { "AWS:SourceArn" = "arn:aws:cloudfront::123456789012:distribution/ECONSUMER" } }
      }]
    })
  }
  assert {
    condition     = aws_s3_bucket_policy.this.policy == var.policy && length(jsondecode(aws_s3_bucket_policy.this.policy).Statement) == 1 && length(aws_s3_bucket_website_configuration.this) == 0 && length(aws_s3_bucket_acl.this) == 0 && aws_s3_bucket_public_access_block.this.block_public_acls && aws_s3_bucket_public_access_block.this.block_public_policy && aws_s3_bucket_public_access_block.this.ignore_public_acls && aws_s3_bucket_public_access_block.this.restrict_public_buckets
    error_message = "Consumer policy must be retained verbatim without extra grants; explicit private controls must be respected."
  }
}
