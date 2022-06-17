resource "aws_s3_bucket" "name" {
  bucket        = var.name
  force_destroy = var.force_destroy
  tags          = var.tags
  acl           = var.acl
  policy        = var.policy == "" ? data.aws_iam_policy_document.origin_website.json : var.policy

  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? [] : [var.website]

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "cors_rule" {
    for_each = try(jsondecode(var.s3_cors_rule), var.s3_cors_rule)

    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  dynamic "versioning" {
    for_each = length(keys(var.versioning)) == 0 ? [] : [var.versioning]

    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})]

        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  # Max 1 block - replication_configuration
  dynamic "replication_configuration" {
    for_each = length(keys(var.replication_configuration)) == 0 ? [] : [var.replication_configuration]

    content {
      role = replication_configuration.value.role

      dynamic "rules" {
        for_each = replication_configuration.value.rules

        content {
          id       = lookup(rules.value, "id", null)
          priority = lookup(rules.value, "priority", null)
          prefix   = lookup(rules.value, "prefix", null)
          status   = lookup(rules.value, "status", null)

          dynamic "destination" {
            for_each = length(keys(lookup(rules.value, "destination", {}))) == 0 ? [] : [lookup(rules.value, "destination", {})]

            content {
              bucket             = lookup(destination.value, "bucket", null)
              storage_class      = lookup(destination.value, "storage_class", null)
              replica_kms_key_id = lookup(destination.value, "replica_kms_key_id", null)
              account_id         = lookup(destination.value, "account_id", null)

              dynamic "access_control_translation" {
                for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

                content {
                  owner = access_control_translation.value.owner
                }
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = length(keys(lookup(rules.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rules.value, "source_selection_criteria", {})]

            content {

              dynamic "sse_kms_encrypted_objects" {
                for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

                content {

                  enabled = sse_kms_encrypted_objects.value.enabled
                }
              }
            }
          }

          dynamic "filter" {
            for_each = length(keys(lookup(rules.value, "filter", {}))) == 0 ? [] : [lookup(rules.value, "filter", {})]

            content {
              prefix = lookup(filter.value, "prefix", null)
              tags   = lookup(filter.value, "tags", null)
            }
          }

        }
      }
    }
  }
}

data "aws_iam_policy_document" "origin_website" {
  statement {
    sid       = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.name}${var.origin_path}*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_notification" "this" {
  count  = length(var.lambda_notifications) > 0 || length(var.sqs_notifications) > 0 || length(var.sns_notifications) > 0 ? 1 : 0
  bucket = var.name

  dynamic "lambda_function" {
    for_each = var.lambda_notifications

    content {
      id                  = lambda_function.key
      lambda_function_arn = lambda_function.value.function_arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  dynamic "queue" {
    for_each = var.sqs_notifications

    content {
      id            = queue.key
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
    }
  }

  dynamic "topic" {
    for_each = var.sns_notifications

    content {
      id            = topic.key
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = lookup(topic.value, "filter_prefix", null)
      filter_suffix = lookup(topic.value, "filter_suffix", null)
    }
  }
}

resource "aws_cloudfront_distribution" "default" {
  count               = var.cloudfront_enabled == true ? 1 : 0
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cloudfront_comment
  default_root_object = var.cloudfront_index_document
  aliases             = var.cloudfront_aliases
  price_class         = var.cloudfront_price_class
  tags                = var.tags

  default_cache_behavior {
    allowed_methods  = var.cloudfront_allowed_methods
    cached_methods   = var.cloudfront_cached_methods
    target_origin_id = var.cloudfront_default_target_origin_id == null ? var.cloudfront_distribution_name : var.cloudfront_default_target_origin_id
    compress         = var.cloudfront_compress
    trusted_signers  = var.cloudfront_trusted_signers

    forwarded_values {
      query_string = var.cloudfront_forward_query_string
      headers      = var.cloudfront_forward_header_values

      cookies {
        forward = var.cloudfront_forward_cookies
      }
    }

    viewer_protocol_policy = var.cloudfront_viewer_protocol_policy
    default_ttl            = var.cloudfront_default_ttl
    min_ttl                = var.cloudfront_min_ttl
    max_ttl                = var.cloudfront_max_ttl
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront_ordered_cache_behavior
    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = lookup(ordered_cache_behavior.value, "allowed_methods", ["GET", "HEAD"])
      cached_methods   = lookup(ordered_cache_behavior.value, "cached_methods", ["GET", "HEAD"])
      target_origin_id = ordered_cache_behavior.value.target_origin_id

      forwarded_values {
        headers                 = lookup(ordered_cache_behavior.value, "headers", [])
        query_string            = lookup(ordered_cache_behavior.value, "query_string", false)
        query_string_cache_keys = lookup(ordered_cache_behavior.value, "query_string_cache_keys", [])

        cookies {
          forward           = lookup(ordered_cache_behavior.value, "forward", "none")
          whitelisted_names = lookup(ordered_cache_behavior.value, "whitelisted_names", [])
        }
      }

      min_ttl                = lookup(ordered_cache_behavior.value, "min_ttl", 0)
      default_ttl            = lookup(ordered_cache_behavior.value, "default_ttl", 86400)
      max_ttl                = lookup(ordered_cache_behavior.value, "max_ttl", 31536000)
      compress               = lookup(ordered_cache_behavior.value, "compress", true)
      viewer_protocol_policy = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", "redirect-to-https")
      smooth_streaming       = lookup(ordered_cache_behavior.value, "smooth_streaming", false)
      trusted_key_groups     = lookup(ordered_cache_behavior.value, "trusted_key_groups", [])
      trusted_signers        = lookup(ordered_cache_behavior.value, "trusted_signers", [])
    }
  }

  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_response
    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  dynamic "origin" {
    for_each = length(var.cloudfront_custom_origins) == 0 ? list(1) : []
    content {
      domain_name = aws_s3_bucket.name.bucket_domain_name
      origin_id   = var.cloudfront_distribution_name
    }
  }

  dynamic "origin" {
    for_each = var.cloudfront_custom_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = lookup(origin.value, "origin_path", "")
      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_headers", [])
        content {
          name  = custom_header.value["name"]
          value = custom_header.value["value"]
        }
      }
      custom_origin_config {
        http_port                = lookup(origin.value, "http_port", 80)
        https_port               = lookup(origin.value, "https_port", 443)
        origin_protocol_policy   = lookup(origin.value, "origin_protocol_policy", "https-only")
        origin_ssl_protocols     = lookup(origin.value, "origin_ssl_protocols", ["TLSv1.2"])
        origin_keepalive_timeout = lookup(origin.value, "origin_keepalive_timeout", 60)
        origin_read_timeout      = lookup(origin.value, "origin_read_timeout", 60)
      }
    }
  }



  dynamic "origin_group" {
    for_each = var.cloudfront_origin_group

    content {
      origin_id = lookup(origin_group.value, "origin_id", origin_group.key)

      failover_criteria {
        status_codes = origin_group.value["failover_status_codes"]
      }

      member {
        origin_id = origin_group.value["primary_member_origin_id"]
      }

      member {
        origin_id = origin_group.value["secondary_member_origin_id"]
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == "" ? "" : "sni-only"
    minimum_protocol_version       = var.cloudfront_minimum_protocol_version
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

data "aws_route53_zone" "default" {
  count   = var.route53_enabled == true ? signum(length(compact(var.cloudfront_aliases))) : 0
  zone_id = var.route53_parent_zone_id
  name    = var.route53_parent_zone_name
}

resource "aws_route53_record" "default" {
  count   = var.route53_enabled == true ? length(compact(var.cloudfront_aliases)) : 0
  zone_id = data.aws_route53_zone.default[0].zone_id
  name    = element(compact(var.cloudfront_aliases), count.index)
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.default[0].domain_name
    zone_id                = aws_cloudfront_distribution.default[0].hosted_zone_id
    evaluate_target_health = var.route53_evaluate_target_health
  }
}
