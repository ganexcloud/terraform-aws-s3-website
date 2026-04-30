locals {
  cloudfront_create_origin_access_identity = var.cloudfront_create_origin_access_identity && length(keys(var.cloudfront_origin_access_identities)) > 0
  s3_acl_grants = flatten([
    for grant in try(jsondecode(var.grant), var.grant) : [
      for permission in lookup(grant, "permissions", [lookup(grant, "permission", null)]) : merge(grant, {
        permission = permission
      })
    ]
  ])
}
