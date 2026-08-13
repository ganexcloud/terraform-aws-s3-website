# terraform-aws-s3-website

Terraform module that provisions an S3 bucket configured for website hosting, with optional CloudFront, Route 53, notifications, lifecycle, encryption, ACL and replication settings.

## Compatibility

This module requires Terraform 1.6.0 or later and supports AWS provider versions from 5.40.0 up to, but not including, 7.0.0.

## Example

See [`examples/complete`](examples/complete).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.40.0, < 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.40.0, < 7.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudfront_response_headers_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_route53_record.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.origin_website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | ACL | `string` | `"private"` | no |
| <a name="input_acl_owner"></a> [acl\_owner](#input\_acl\_owner) | ACL owner configuration. If omitted, the current AWS canonical user ID is used. | `map(string)` | `{}` | no |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of Certificate | `string` | `""` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for this bucket. | `bool` | `false` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `false` | no |
| <a name="input_cloudfront_aliases"></a> [cloudfront\_aliases](#input\_cloudfront\_aliases) | List of cloudfront\_aliases | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_cloudfront_allowed_methods"></a> [cloudfront\_allowed\_methods](#input\_cloudfront\_allowed\_methods) | List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront | `list(string)` | <pre>[<br/>  "GET",<br/>  "HEAD"<br/>]</pre> | no |
| <a name="input_cloudfront_cache_policy_id"></a> [cloudfront\_cache\_policy\_id](#input\_cloudfront\_cache\_policy\_id) | (Optional) - The unique identifier of the cache policy that is attached to the cache behavior. | `string` | `""` | no |
| <a name="input_cloudfront_cached_methods"></a> [cloudfront\_cached\_methods](#input\_cloudfront\_cached\_methods) | List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD) | `list(string)` | <pre>[<br/>  "GET",<br/>  "HEAD"<br/>]</pre> | no |
| <a name="input_cloudfront_comment"></a> [cloudfront\_comment](#input\_cloudfront\_comment) | Cloudfront comments | `string` | `""` | no |
| <a name="input_cloudfront_compress"></a> [cloudfront\_compress](#input\_cloudfront\_compress) | Compress content for web requests that include Accept-Encoding: gzip in the request header | `bool` | `false` | no |
| <a name="input_cloudfront_create_origin_access_identity"></a> [cloudfront\_create\_origin\_access\_identity](#input\_cloudfront\_create\_origin\_access\_identity) | Controls if CloudFront origin access identity should be created | `bool` | `false` | no |
| <a name="input_cloudfront_custom_error_response"></a> [cloudfront\_custom\_error\_response](#input\_cloudfront\_custom\_error\_response) | List of one or more custom error response element maps | <pre>list(object({<br/>    error_caching_min_ttl = number<br/>    error_code            = number<br/>    response_code         = number<br/>    response_page_path    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cloudfront_custom_origins"></a> [cloudfront\_custom\_origins](#input\_cloudfront\_custom\_origins) | One or more custom origins for this distribution (multiples allowed). See documentation for configuration options description https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments | `any` | `[]` | no |
| <a name="input_cloudfront_default_target_origin_id"></a> [cloudfront\_default\_target\_origin\_id](#input\_cloudfront\_default\_target\_origin\_id) | The value of ID for the origin that you want CloudFront to route requests to the default cache behavior | `string` | `null` | no |
| <a name="input_cloudfront_default_ttl"></a> [cloudfront\_default\_ttl](#input\_cloudfront\_default\_ttl) | Default amount of time (in seconds) that an object is in a CloudFront cache | `number` | `86400` | no |
| <a name="input_cloudfront_distribution_name"></a> [cloudfront\_distribution\_name](#input\_cloudfront\_distribution\_name) | The name of the distribution. | `string` | `""` | no |
| <a name="input_cloudfront_enabled"></a> [cloudfront\_enabled](#input\_cloudfront\_enabled) | Enable Cloudfront | `bool` | `false` | no |
| <a name="input_cloudfront_forward_cookies"></a> [cloudfront\_forward\_cookies](#input\_cloudfront\_forward\_cookies) | Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none' | `string` | `"none"` | no |
| <a name="input_cloudfront_forward_header_values"></a> [cloudfront\_forward\_header\_values](#input\_cloudfront\_forward\_header\_values) | A list of whitelisted header values to forward to the origin | `list(string)` | `[]` | no |
| <a name="input_cloudfront_forward_query_string"></a> [cloudfront\_forward\_query\_string](#input\_cloudfront\_forward\_query\_string) | Forward query strings to the origin that is associated with this cache behavior | `bool` | `false` | no |
| <a name="input_cloudfront_function_association"></a> [cloudfront\_function\_association](#input\_cloudfront\_function\_association) | (Optional) - A config block that triggers a cloudfront function with specific actions (maximum 2). | `any` | `{}` | no |
| <a name="input_cloudfront_http_version"></a> [cloudfront\_http\_version](#input\_cloudfront\_http\_version) | The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3, and http3. The default is http2. | `string` | `"http2"` | no |
| <a name="input_cloudfront_index_document"></a> [cloudfront\_index\_document](#input\_cloudfront\_index\_document) | Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders | `string` | `"index.html"` | no |
| <a name="input_cloudfront_lambda_function_association"></a> [cloudfront\_lambda\_function\_association](#input\_cloudfront\_lambda\_function\_association) | (Optional) - A config block that triggers a lambda function with specific actions (maximum 4). | `any` | `{}` | no |
| <a name="input_cloudfront_max_ttl"></a> [cloudfront\_max\_ttl](#input\_cloudfront\_max\_ttl) | Maximum amount of time (in seconds) that an object is in a CloudFront cache | `number` | `31536000` | no |
| <a name="input_cloudfront_min_ttl"></a> [cloudfront\_min\_ttl](#input\_cloudfront\_min\_ttl) | Minimum amount of time that you want objects to stay in CloudFront caches | `number` | `0` | no |
| <a name="input_cloudfront_minimum_protocol_version"></a> [cloudfront\_minimum\_protocol\_version](#input\_cloudfront\_minimum\_protocol\_version) | Cloudfront TLS minimum protocol version | `string` | `"TLSv1.1_2016"` | no |
| <a name="input_cloudfront_ordered_cache_behavior"></a> [cloudfront\_ordered\_cache\_behavior](#input\_cloudfront\_ordered\_cache\_behavior) | (Optional) - An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0. | `any` | `[]` | no |
| <a name="input_cloudfront_origin_access_identities"></a> [cloudfront\_origin\_access\_identities](#input\_cloudfront\_origin\_access\_identities) | Map of CloudFront origin access identities (value as a comment) | `map(string)` | `{}` | no |
| <a name="input_cloudfront_origin_group"></a> [cloudfront\_origin\_group](#input\_cloudfront\_origin\_group) | One or more origin\_group for this distribution (multiples allowed). | `any` | `{}` | no |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | Price class for this distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100` | `string` | `"PriceClass_All"` | no |
| <a name="input_cloudfront_response_headers_policy"></a> [cloudfront\_response\_headers\_policy](#input\_cloudfront\_response\_headers\_policy) | (Optional) Provides a CloudFront response headers policy resource. A response headers policy contains information about a set of HTTP response headers and their values. After you create a response headers policy, you can use its ID to attach it to one or more cache behaviors in a CloudFront distribution. When it’s attached to a cache behavior, CloudFront adds the headers in the policy to every response that it sends for requests that match the cache behavior. | `any` | `{}` | no |
| <a name="input_cloudfront_response_headers_policy_id"></a> [cloudfront\_response\_headers\_policy\_id](#input\_cloudfront\_response\_headers\_policy\_id) | (Optional) The identifier for a response headers policy. If response\_headers\_policy is true the name of policy is used. | `string` | `null` | no |
| <a name="input_cloudfront_trusted_signers"></a> [cloudfront\_trusted\_signers](#input\_cloudfront\_trusted\_signers) | The AWS accounts, if any, that you want to allow to create signed URLs for private content. 'self' is acceptable. | `list(string)` | `[]` | no |
| <a name="input_cloudfront_use_forwarded_values"></a> [cloudfront\_use\_forwarded\_values](#input\_cloudfront\_use\_forwarded\_values) | Enable forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers (maximum one). | `bool` | `true` | no |
| <a name="input_cloudfront_viewer_protocol_policy"></a> [cloudfront\_viewer\_protocol\_policy](#input\_cloudfront\_viewer\_protocol\_policy) | allow-all, redirect-to-https | `string` | `"redirect-to-https"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Delete all objects in bucket on destroy | `bool` | `false` | no |
| <a name="input_grant"></a> [grant](#input\_grant) | ACL policy grants to apply through aws\_s3\_bucket\_acl. Supports either permission or permissions for compatibility with terraform-aws-s3-bucket style inputs. | `any` | `[]` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for this bucket. | `bool` | `false` | no |
| <a name="input_lambda_notifications"></a> [lambda\_notifications](#input\_lambda\_notifications) | Map of S3 bucket notifications to Lambda function | `any` | `{}` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | List of maps containing configuration of object lifecycle management. | `any` | `[]` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | (Optional) Name of the bucket where S3 server access logs will be delivered. | `string` | `""` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | (Optional) Prefix for S3 server access log objects. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of s3 bucket | `string` | n/a | yes |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Object Ownership has three settings that you can use to control ownership of objects uploaded to your bucket and to disable (BucketOwnerEnforced) or enable ACLs (BucketOwnerPreferred or ObjectWriter) | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_origin_path"></a> [origin\_path](#input\_origin\_path) | An optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin. It must begin with a /. Do not add a / at the end of the path. | `string` | `"/"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid bucket policy JSON document | `string` | `""` | no |
| <a name="input_replication_configuration"></a> [replication\_configuration](#input\_replication\_configuration) | Map containing cross-region bucket replication configuration. | `any` | `{}` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket. | `bool` | `false` | no |
| <a name="input_route53_enabled"></a> [route53\_enabled](#input\_route53\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_route53_evaluate_target_health"></a> [route53\_evaluate\_target\_health](#input\_route53\_evaluate\_target\_health) | Set to true if you want Route 53 to determine whether to respond to DNS queries | `bool` | `false` | no |
| <a name="input_route53_parent_zone_id"></a> [route53\_parent\_zone\_id](#input\_route53\_parent\_zone\_id) | ID of the hosted zone to contain this record  (or specify `parent_zone_name`) | `string` | `""` | no |
| <a name="input_route53_parent_zone_name"></a> [route53\_parent\_zone\_name](#input\_route53\_parent\_zone\_name) | Name of the hosted zone to contain this record (or specify `parent_zone_id`) | `string` | `""` | no |
| <a name="input_s3_cors_rule"></a> [s3\_cors\_rule](#input\_s3\_cors\_rule) | (Optional) List of maps containing rules for Cross-Origin Resource Sharing. | `any` | `[]` | no |
| <a name="input_server_side_encryption_configuration"></a> [server\_side\_encryption\_configuration](#input\_server\_side\_encryption\_configuration) | Map containing server-side encryption configuration. | `any` | `{}` | no |
| <a name="input_sns_notifications"></a> [sns\_notifications](#input\_sns\_notifications) | Map of S3 bucket notifications to SNS topic | `any` | `{}` | no |
| <a name="input_sqs_notifications"></a> [sqs\_notifications](#input\_sqs\_notifications) | Map of S3 bucket notifications to SQS queue | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional Tags | `map(string)` | `{}` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Map containing versioning configuration. | `map(string)` | `{}` | no |
| <a name="input_website"></a> [website](#input\_website) | Map containing static web-site hosting or redirect configuration. | `map(string)` | <pre>{<br/>  "error_document": "index.html",<br/>  "index_document": "index.html"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S3 Bucket project. |
| <a name="output_bucket_demain_name"></a> [bucket\_demain\_name](#output\_bucket\_demain\_name) | S3 Bucket Domain Name |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | S3 Bucket Name |
| <a name="output_cloudfront_arn"></a> [cloudfront\_arn](#output\_cloudfront\_arn) | The ARN (Amazon Resource Name) for the distribution. |
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | The domain name corresponding to the distribution. |
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | The identifier for the cloudfront distribution |
<!-- END_TF_DOCS -->
