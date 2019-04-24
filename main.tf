resource "aws_s3_bucket" "name" {
  bucket        = "${var.name}"
  force_destroy = "${var.force_destroy}"
  tags          = "${var.tags}"
  policy        = "${var.policy}"
  acl           = "${var.acl}"

  versioning {
    enabled = "${var.versioned}"
  }
}
