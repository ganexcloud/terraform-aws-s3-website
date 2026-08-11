module "s3_website" {
  source = "../../"

  name                = "ganex-s3-website-example"
  cloudfront_enabled  = true
  cloudfront_aliases  = []
  acm_certificate_arn = "arn:aws:acm:us-east-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"

  cloudfront_distribution_name = "ganex-s3-website-example"
  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Example = "terraform-aws-s3-website"
  }
}
