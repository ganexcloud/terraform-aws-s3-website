module "s3-NAME" {
  source = "git::https://gitlab.com/ganex-cloud/terraform/terraform-aws-s3-website?ref=master"
  name   = "NAME"
  policy = "${file("files/POLICYFILE.json")}"

  tags = {
    Name = "Bucket S3"
  }

  index_document = "index.html"
  error_document = "index.html"

  cloudfront_enabled                = "true"
  cloudfront_distribution_name      = "DISTRIBUTION-NAME"
  cloudfront_aliases                = ["www.domain.com"]
  cloudfront_viewer_protocol_policy = "redirect-to-https"
  acm_certificate_arn               = "arn:aws:acm:us-east-1:xxxxxx:certificate/xxxxx-xxxxxxxx-xxxxxxxxxx"

  custom_error_response = [
    {
      error_caching_min_ttl = "0"
      error_code            = "403"
      response_code         = "200"
      response_page_path    = "/index.html"
    },
    {
      error_caching_min_ttl = "0"
      error_code            = "404"
      response_code         = "200"
      response_page_path    = "/index.html"
    },
  ]

  route53_enabled          = "true"
  route53_parent_zone_name = "domain.com"
}
