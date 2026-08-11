# Contributing

Pull requests are validated by the `validate` workflow. Run the same checks locally before opening a pull request:

```sh
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
pre-commit run --all-files
```
