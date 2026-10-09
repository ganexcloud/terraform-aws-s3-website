mock_provider "aws" {
  override_during = plan
  mock_resource "aws_s3_bucket" {
    defaults = {
      id                          = "example-site"
      arn                         = "arn:aws:s3:::example-site"
      bucket_domain_name          = "example-site.s3.amazonaws.com"
      bucket_regional_domain_name = "example-site.s3.us-east-1.amazonaws.com"
    }
  }
  mock_resource "aws_cloudfront_distribution" {
    defaults = {
      id          = "EEXAMPLEDISTRIBUTION"
      arn         = "arn:aws:cloudfront::123456789012:distribution/EEXAMPLEDISTRIBUTION"
      domain_name = "example.cloudfront.net"
    }
  }
  mock_resource "aws_cloudfront_origin_access_control" {
    defaults = { id = "EEXAMPLEOAC" }
  }
  mock_resource "aws_cloudfront_cache_policy" {
    defaults = { id = "11111111-1111-1111-1111-111111111111" }
  }
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
}

run "private_consumer_policy_without_cycle" {
  command = plan
  module { source = "./examples/private" }
  variables {
    name                = "example-site"
    acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = jsondecode(output.bucket_policy).Statement[0].Resource == "arn:aws:s3:::example-site/releases/*" && jsondecode(output.bucket_policy).Statement[0].Principal.Service == "cloudfront.amazonaws.com" && jsondecode(output.bucket_policy).Statement[0].Condition.StringEquals["AWS:SourceArn"] == output.cloudfront_arn
    error_message = "The consumer policy must restrict its grant to releases/* and this distribution."
  }
  assert {
    condition     = output.cloudfront_origin_access_control_id == "EEXAMPLEOAC" && output.cloudfront_cache_policy_id == "11111111-1111-1111-1111-111111111111"
    error_message = "The private example must create its optional policies."
  }
}

run "existing_policies_example" {
  command = plan
  module { source = "./examples/existing-policies" }
  variables {
    name                     = "example-site"
    origin_access_control_id = "EEXTERNALOAC"
    acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = output.created_origin_access_control_id == null && output.created_cache_policy_id == null
    error_message = "The existing-policies example must reuse policies without creating any."
  }
}
