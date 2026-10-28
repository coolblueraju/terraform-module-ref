# parameterstore-infra

Reusable Terraform module for creating one AWS Systems Manager Parameter Store entry per module call.

## Package contents
- `versions.tf`: Terraform and AWS provider requirements.
- `locals.tf`: fixed UMB tag map. Unlike workspace-based modules, `var.env` is used directly.
- `variables.tf`: module inputs and validations.
- `main.tf`: `aws_ssm_parameter.parameter`.
- `outputs.tf`: parameter name, ARN, and current version.
- `examples/`: String, SecureString, StringList, and caller-level `for_each` examples.

## Line-by-line guide

### `versions.tf`
`required_version` sets Terraform 1.5+ as the module floor. The AWS provider is sourced from HashiCorp and requires version 5.0 or newer.

### `locals.tf`
The `tags` local builds the standard application metadata tags. `umbEnvironment` uses `var.env` exactly as supplied. There is deliberately no Terraform-workspace conversion in this module, preserving the supplied contract.

### `variables.tf`
`parameter_name` is the complete SSM path. The validation requires an absolute path starting with `/`, such as `/myapp/prod/db/password`.

`parameter_value` is marked `sensitive = true`. This prevents routine CLI/UI display in many Terraform contexts, but it does not remove the value from Terraform state.

`parameter_type` is restricted to `String`, `StringList`, or `SecureString`.

The application metadata variables populate tags only.

### `main.tf`
`aws_ssm_parameter.parameter` uses the caller-provided name, type, and value verbatim and applies the fixed UMB tags. There is intentionally no `key_id`, so SecureString follows the module's documented default-key behavior rather than exposing a customer-managed KMS key input.

### `outputs.tf`
`parameter_name` identifies the created parameter, `parameter_arn` is useful for IAM policies, and `parameter_version` changes as SSM produces new parameter versions.

## Common_TF_Modules usage
Use the module source as plain HCL:

```hcl
module "feature_flag" {
  source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/parameterstore-infra/?ref=v4.0.0"

  parameter_name  = "/myapp/${var.env}/feature/new-ui-enabled"
  parameter_type  = "String"
  parameter_value = "true"

  app_short_name = "myapp"
  env            = var.env

  application_owner_email = var.application_owner_email
  project_ritm            = var.project_ritm
  git_repo_name           = var.git_repo_name
  cmdb_id                 = var.cmdb_id
}
```

Do not paste the rendered HTML anchor tag into `source`.

## SecureString example

```hcl
module "db_password" {
  source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/parameterstore-infra/?ref=v4.0.0"

  parameter_name  = "/myapp/${var.env}/db/password"
  parameter_type  = "SecureString"
  parameter_value = var.db_password

  app_short_name = "myapp"
  env            = var.env
  application_owner_email = var.application_owner_email
  project_ritm   = var.project_ritm
  git_repo_name  = var.git_repo_name
  cmdb_id        = var.cmdb_id
}
```

## Multiple parameters
The module creates one parameter. Use `for_each` around the module to create several while keeping one reusable implementation. A complete example is under `examples/for-each`.

## PowerShell deployment
```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

For a sensitive input, prefer supplying the value from your secure CI/CD secret store rather than hardcoding it in `.tf` or `.tfvars` checked into Git.

## Security notes
1. `sensitive = true` does not encrypt or remove the parameter value from Terraform state. Secure the backend with encryption and strict IAM/RBAC.
2. `SecureString` protects the value in SSM, but this module does not expose a customer-managed KMS key. Add a `kms_key_id`/`key_id` input in a versioned module enhancement if CMK control is required.
3. Do not expose sensitive outputs containing `parameter_value`. This module intentionally outputs metadata only.
4. There are no `additional_tags` or `apprepo_tags`, preserving the supplied contract.
