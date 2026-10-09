# Contributing

Pull requests are validated by the `validate` workflow. Run the same checks locally before opening a pull request:

```sh
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
pre-commit run --all-files
bash scripts/validate-provider.sh 5.40.0
bash scripts/validate-provider.sh 6.68.0
```

Use Terraform 1.15.8 for mocked plan tests. The script validates the root and examples in temporary fixtures without AWS access. CI also validates Terraform 1.6.0 with `compat` mode, initializing providers with 1.15.8 for signature verification. To reproduce that check locally, select the binaries with `TERRAFORM_BIN` and `TERRAFORM_INIT_BIN`. Keep tests mocked and plan-only.
