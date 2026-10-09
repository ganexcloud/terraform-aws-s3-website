locals {
  cloudfront_has_external_cache_policy     = try(length(var.cloudfront_cache_policy_id) > 0, false)
  cloudfront_use_legacy_forwarding         = var.cloudfront_cache_policy == null && var.cloudfront_use_forwarded_values
  cloudfront_create_origin_access_identity = var.cloudfront_create_origin_access_identity && length(keys(var.cloudfront_origin_access_identities)) > 0
  s3_acl_grants = flatten([
    for grant in try(jsondecode(var.grant), var.grant) : [
      for permission in lookup(grant, "permissions", [lookup(grant, "permission", null)]) : merge(grant, {
        permission = permission
      })
    ]
  ])
}
