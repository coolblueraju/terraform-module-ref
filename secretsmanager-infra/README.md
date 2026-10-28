# secretsmanager-infra

Reusable Terraform module for one AWS Secrets Manager secret container and one Terraform-managed secret version.

## Files
- `versions.tf`: Terraform and AWS provider requirements.
- `locals.tf`: fixed UMB tags using `var.env` directly.
- `variables.tf`: inputs and validation, including recovery-window enforcement.
- `main.tf`: secret container and initial/current Terraform-managed value.
- `outputs.tf`: secret name, ARN, ID, and version ID.
- `examples/`: plain string, JSON credentials, and `for_each` examples.

## Line-by-line guide
### Secret container
`aws_secretsmanager_secret.secret` uses `secret_name` verbatim and does not impose a naming convention. `secret_description` defaults to empty. `recovery_window_in_days` defaults to 30 and is validated as either 0 or 7-30 days. A value of 0 requests immediate deletion behavior when Terraform destroys the secret; use that only when intentionally accepting the loss of the recovery window.

### Secret version
`aws_secretsmanager_secret_version.secret_version` attaches `secret_value` to the secret. It supports a plain string or a JSON string produced through `jsonencode`. Terraform manages that value, so the sensitive material is present in Terraform state even though the input variable itself is marked `sensitive`.

### Tags
The module applies the fixed UMB application, environment, owner, RITM, Git repository, CMDB, and Terraform tags. `env` is used directly. There are deliberately no `additional_tags` or `apprepo_tags` inputs, preserving the supplied interface.

### Encryption
No `kms_key_id` input is provided, preserving the supplied module design. If your application requires a customer-managed KMS key, add a versioned module enhancement instead of modifying individual application copies.

### Outputs
Outputs contain only secret metadata, not `secret_value`. `secret_version_id` identifies the Terraform-managed version.

## Common_TF_Modules usage
Use a plain Git source string rather than rendered HTML:
```hcl
source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/secretsmanager-infra/?ref=v4.0.0"
```

## Secure delivery of input values
Avoid storing secrets in checked-in `.tfvars`. Supply them from a protected CI/CD secret store or a secured `TF_VAR_...` environment variable. Remember that Terraform still persists the resulting managed value in state.

## Multiple secrets
One module call creates one secret. `examples/for-each` demonstrates using caller-level `for_each` for multiple values while retaining a simple module implementation.

## Deployment
```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Rotation and drift
This module is appropriate when Terraform owns the secret value. If AWS Secrets Manager rotation, a Lambda rotation function, or an external secret-rotation platform owns future versions, Terraform ownership of `secret_string` needs deliberate lifecycle/design changes. Otherwise a subsequent Terraform deployment can conflict with independently rotated values or attempt to restore the Terraform-configured value.

## Security cautions
1. Marking `secret_value` sensitive prevents common display but does not remove it from state.
2. Encrypt the Terraform backend and tightly restrict state read access.
3. `recovery_window_in_days = 0` removes the normal recovery buffer and should generally be avoided for production secrets.
4. Do not output secret values from caller modules.
