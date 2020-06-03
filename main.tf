resource "aws_s3_bucket" "name" {
  bucket        = var.name
  force_destroy = var.force_destroy
  tags          = var.tags
  policy        = var.policy
  acl           = var.acl

  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? [] : [var.website]

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  versioning {
    enabled = var.versioned
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

resource "aws_s3_bucket_policy" "default" {
  bucket = var.name
  policy = data.aws_iam_policy_document.origin_website.json
}

resource "aws_cloudfront_distribution" "default" {
  count               = var.cloudfront_enabled == true ? 1 : 0
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cloudfront_comment
  default_root_object = var.cloudfront_index_document
  aliases             = var.cloudfront_aliases
  price_class         = var.cloudfront_price_class

  default_cache_behavior {
    allowed_methods  = var.cloudfront_allowed_methods
    cached_methods   = var.cloudfront_cached_methods
    target_origin_id = var.cloudfront_distribution_name
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

  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_response
    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  origin {
    domain_name = aws_s3_bucket.name.bucket_domain_name
    origin_id   = var.cloudfront_distribution_name
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
