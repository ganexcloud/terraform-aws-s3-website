locals {
  cloudfront_create_origin_access_identity = var.cloudfront_create_origin_access_identity && length(keys(var.cloudfront_origin_access_identities)) > 0

  owner_full_control_acl_grant = [
    {
      id          = data.aws_canonical_user_id.current.id
      type        = "CanonicalUser"
      permissions = ["FULL_CONTROL"]
      uri         = null
    }
  ]

  acl_grants_include_owner_full_control = length([
    for grant in var.acl_grants : grant
    if lookup(grant, "type", null) == "CanonicalUser" && lookup(grant, "id", null) == data.aws_canonical_user_id.current.id && contains(lookup(grant, "permissions", []), "FULL_CONTROL")
  ]) > 0

  effective_acl_grants = flatten([
    slice(local.owner_full_control_acl_grant, 0, length(var.acl_grants) == 0 || local.acl_grants_include_owner_full_control ? 0 : 1),
    var.acl_grants,
  ])
}
