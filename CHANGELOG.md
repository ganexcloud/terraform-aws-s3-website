# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1](https://github.com/ganexcloud/terraform-aws-s3-website/compare/v1.0.0...v1.0.1) (2026-08-13)

### Bug Fixes

* **s3-website:** migrate deprecated s3 configuration ([#3](https://github.com/ganexcloud/terraform-aws-s3-website/issues/3)) ([15e7be7](https://github.com/ganexcloud/terraform-aws-s3-website/commit/15e7be71e7870bd7f243afa575551091e925108f))

## [1.0.0](https://github.com/ganexcloud/terraform-aws-s3-website/compare/v0.1.0...v1.0.0) (2026-08-11)

### ⚠ BREAKING CHANGES

* **s3-website:** stabilize the v1 module contract without removing public inputs or outputs.

### Features

* **s3-website:** modernize module for terraform 1.6 ([b84c6ac](https://github.com/ganexcloud/terraform-aws-s3-website/commit/b84c6ac3d3eb3d8854f0c582ee92b0442827a44d))

## [1.0.0](https://github.com/ganexcloud/terraform-aws-cloud-custodian/compare/v0.1.0...v1.0.0) (2026-08-07)

### ⚠ BREAKING CHANGES

* stabilize the public v1 module contract without removing variables or outputs.

* fix(ci): skip mock tests on Terraform 1.6

* fix(ci): use local provider mirror for Terraform 1.6

* fix(ci): align validation with terraform-aws-budget template

### Features

* modernize terraform-aws-cloud-custodian module ([#1](https://github.com/ganexcloud/terraform-aws-cloud-custodian/issues/1)) ([026981e](https://github.com/ganexcloud/terraform-aws-cloud-custodian/commit/026981e1134d04ba75d5afa4228a450d84fe627f))
