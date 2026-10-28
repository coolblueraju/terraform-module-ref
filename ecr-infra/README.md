# ecr-infra

Reusable Terraform wrapper module for an application ECR repository. The top-level module delegates resource creation to the local `./ecr` submodule, matching the supplied Common_TF_Modules design.

## Package layout

- `versions.tf`: Terraform and AWS provider requirements.
- `variables.tf`: public/pass-through input contract.
- `main.tf`: calls `./ecr`.
- `outputs.tf`: re-exports `ecr_repo_url`.
- `ecr/locals.tf`: repository naming, workspace mapping, and standard tag merging.
- `ecr/variables.tf`: nested inputs, including `encrypt_type = "AES256"`.
- `ecr/main.tf`: ECR repository and two-image lifecycle policy.
- `ecr/outputs.tf`: repository URL.
- `examples/`: workspace-oriented usage examples.

## Line-by-line guide

### Top-level wrapper

`module "ecr"` uses `source = "./ecr"`, so the wrapper itself creates no AWS resource. It passes application identity and tagging inputs to the nested submodule. `outputs.tf` exposes `module.ecr.ecr_repo_url`, allowing consumers to use `module.ecr.ecr_repo_url` from their application Terraform.

### Nested naming

`local.ecr_name = "${var.app_short_name}-ecr"` produces names such as `myapp-ecr`. Environment is deliberately not included in the resource name.

### Workspace-to-tag mapping

The supplied design depends on Terraform workspace rather than the `env` input for the environment tag:

- workspace `test` -> tag value `dev`
- workspace `qa` -> tag value `qa`
- workspace `prod` -> tag value `prod`

A resource precondition now produces a clear error for any other workspace instead of allowing an obscure lookup failure. This preserves the three-workspace requirement.

### Tag merging

`common_tags` contains application, mapped environment, owner, RITM, repository, CMDB, and Terraform ownership metadata. `merge(local.common_tags, var.apprepo_tags)` places `apprepo_tags` last, so matching custom keys have highest precedence.

### Repository

`aws_ecr_repository.ecr` creates `<app_short_name>-ecr`. `scan_on_push = true` enables ECR image scanning on push. `encryption_configuration` uses the nested `encrypt_type`, defaulting to `AES256`.

The top-level wrapper intentionally does not expose `encrypt_type`, matching your supplied contract. If KMS becomes a requirement, expose that variable through the wrapper in a new module revision rather than asking application teams to edit vendored module code.

`image_tag_mutability` is intentionally not specified, preserving the supplied behavior where the AWS/provider default applies.

### Lifecycle policy

`aws_ecr_lifecycle_policy.ecr_lifecycle_policy` selects `tagStatus = "any"`, `countType = "imageCountMoreThan"`, and `countNumber = 2`. Once more than two images exist, older images become eligible for expiration according to the ECR lifecycle policy. This is an aggressive retention setting for production rollback scenarios.

## Common_TF_Modules usage

Use a plain Terraform Git string rather than HTML copied from a rendered link:

```hcl
module "ecr" {
  source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/ecr-infra/?ref=v4.0.0"

  app_short_name = "myapp"
  env            = var.env

  application_owner_email = var.application_owner_email
  project_ritm            = var.project_ritm
  git_repo_name           = var.git_repo_name
  cmdb_id                 = var.cmdb_id
}
```

## Workspace setup

This module must run from `test`, `qa`, or `prod`.

PowerShell example for QA:

```powershell
terraform init
terraform workspace list
terraform workspace select qa
```

If the workspace does not yet exist:

```powershell
terraform workspace new qa
```

Then:

```powershell
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output ecr_repo_url
```

## Push an image

After deployment, get the repository URL:

```powershell
terraform output -raw ecr_repo_url
```

Authenticate and push, replacing account/region as appropriate:

```powershell
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-2.amazonaws.com
docker build -t myapp-ecr:v1 .
docker tag myapp-ecr:v1 123456789012.dkr.ecr.us-east-2.amazonaws.com/myapp-ecr:v1
docker push 123456789012.dkr.ecr.us-east-2.amazonaws.com/myapp-ecr:v1
```

## Operational cautions

1. Only two images are retained by the lifecycle policy. Before production adoption, confirm two images provide sufficient rollback depth for your deployment frequency.
2. `env` is accepted but does not control `umbEnvironment`; Terraform workspace does. Ensure your application pipeline does not accidentally run the prod account using the `test` or `qa` workspace.
3. The wrapper exposes no KMS configuration. The nested submodule validates `AES256` or `KMS`, but top-level consumers cannot select KMS without changing the wrapper interface.
4. Scan-on-push is enabled, but your CI/CD security gate still needs to decide what to do with discovered vulnerabilities.
