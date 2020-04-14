resource "aws_s3_bucket" "name" {
  bucket        = "${var.name}"
  force_destroy = "${var.force_destroy}"
  tags          = "${var.tags}"
  policy        = "${var.policy}"
  acl           = "${var.acl}"

  website = {
    index_document = "${var.index_document}"
    error_document = "${var.error_document}"
  }

  versioning {
    enabled = "${var.versioned}"
  }
}

resource "aws_cloudfront_distribution" "default" {
  count               = "${var.cloudfront_enabled == "true" ? 1 : 0}"
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.cloudfront_comment}"
  default_root_object = "${var.index_document}"
  aliases             = ["${var.cloudfront_aliases}"]
  price_class         = "${var.cloudfront_price_class}"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.cloudfront_distribution_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "${var.cloudfront_viewer_protocol_policy}"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  custom_error_response = ["${var.custom_error_response}"]

  origin {
    domain_name = "${aws_s3_bucket.name.bucket_domain_name}"
    origin_id   = "${var.cloudfront_distribution_name}"
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

data "aws_route53_zone" "default" {
  count   = "${var.route53_enabled == "true" ? signum(length(compact(var.cloudfront_aliases))) : 0}"
  zone_id = "${var.route53_parent_zone_id}"
  name    = "${var.route53_parent_zone_name}"
}

resource "aws_route53_record" "default" {
  count   = "${var.route53_enabled == "true" ? length(compact(var.cloudfront_aliases)) : 0}"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${element(compact(var.cloudfront_aliases), count.index)}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.default.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.default.hosted_zone_id}"
    evaluate_target_health = "${var.route53_evaluate_target_health}"
  }
}
