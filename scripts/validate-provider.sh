#!/usr/bin/env bash
set -euo pipefail

# Keep provider locks and minimum-runtime checks outside the reusable module.
provider_version="${1:?Usage: validate-provider.sh <aws-version> [compat]}"
validation_mode="${2:-test}"
terraform_bin="${TERRAFORM_BIN:-terraform}"
terraform_init_bin="${TERRAFORM_INIT_BIN:-$terraform_bin}"
if [[ ! "$provider_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$validation_mode" != test && "$validation_mode" != compat ]]; then
  printf 'Expected an exact provider version and test or compat mode.\n' >&2
  exit 2
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_dir="$(mktemp -d /tmp/s3-website-validation.XXXXXX)"
trap 'rm -rf -- "$fixture_dir"' EXIT
mkdir -p "$fixture_dir/provider-cache"
export TF_PLUGIN_CACHE_DIR="$fixture_dir/provider-cache"

cp "$repo_dir"/*.tf "$fixture_dir/"
mkdir -p "$fixture_dir/examples"
for example_dir in "$repo_dir"/examples/*; do
  example_name="$(basename "$example_dir")"
  mkdir -p "$fixture_dir/examples/$example_name"
  cp "$example_dir"/*.tf "$fixture_dir/examples/$example_name/"
done
if [[ "$validation_mode" == test ]]; then
  cp -R "$repo_dir/tests" "$fixture_dir/tests"
fi

for validation_dir in "$fixture_dir" "$fixture_dir"/examples/*; do
  printf 'terraform {\n  required_providers {\n    aws = {\n      source = "hashicorp/aws"\n      version = "= %s"\n    }\n  }\n}\n' "$provider_version" > "$validation_dir/provider-version_override.tf"
  "$terraform_init_bin" -chdir="$validation_dir" init -backend=false -input=false -no-color
  "$terraform_bin" -chdir="$validation_dir" validate -no-color
done

"$terraform_bin" -chdir="$fixture_dir" version
if [[ "$validation_mode" == test ]]; then
  # Every test uses mock_provider and command=plan; no AWS API calls or resources.
  AWS_EC2_METADATA_DISABLED=true "$terraform_bin" -chdir="$fixture_dir" test -no-color
fi
