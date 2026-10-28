# batch-infra

Reusable Terraform module that provisions one complete AWS Batch job pipeline: compute environment, queue, job definition, ECR repository, IAM roles, security group, and CloudWatch Logs group.

## Package contents

| File | Responsibility |
|---|---|
| `versions.tf` | Terraform and AWS provider requirements |
| `data.tf` | Caller, region, default VPC, and private-subnet lookups |
| `locals.tf` | Compute-type switches, fallback names, effective network values, image URI, environment list, and tags |
| `variables.tf` | Inputs, defaults, types, and validation |
| `main.tf` | ECR, logging, networking, IAM, Batch compute environment, queue, and job definition |
| `outputs.tf` | Resource names, ARNs, image URI, and log-group name |
| `terraform.tfvars.example` | Example consumer values |
| `examples/` | Fargate, EC2, custom-image, and custom-network examples |

## Resource flow

1. Terraform discovers the active account, provider region, default VPC, and matching private subnets.
2. The module creates a dedicated ECR repository and keeps its latest 30 images.
3. IAM roles are created for AWS Batch, EC2 instances when required, Spot Fleet when required, ECS task execution, and the application job.
4. A CloudWatch log group and optional default security group are created.
5. The managed Batch compute environment is created with Fargate, Fargate Spot, EC2, or EC2 Spot capacity.
6. The queue points to that compute environment.
7. The job definition uses either `container_image` or the module ECR repository plus `batch_image_tag`.

## Detailed file explanation

### `versions.tf`

- `terraform.required_version` requires Terraform 1.5 or newer because the module uses lifecycle preconditions.
- `required_providers.aws.source` selects the official HashiCorp AWS provider.
- `required_providers.aws.version` allows AWS provider 5.x or newer.

### `data.tf`

- `aws_caller_identity.current` reads the account used by the current AWS credentials.
- `aws_region.current` reads the region configured on the AWS provider.
- `aws_vpc.default` locates the account's default VPC.
- `aws_subnets.private_pattern_one` finds private subnets named like `*privatesubnet-az1`, `az2`, or `az3`.
- `aws_subnets.private_pattern_two` finds private subnets named like `*private-subnet-us-east-2a`, `b`, or `c`.
- If your account has no default VPC or your names differ, provide `subnet_ids` and consider adapting the VPC lookup for your enterprise network.

### `locals.tf`

- `is_fargate` is `true` for `FARGATE` and `FARGATE_SPOT`.
- `platform_capability` becomes `FARGATE` or `EC2` for the job definition.
- `effective_ecr_repository_name` uses the explicit override, otherwise `<app_short_name>-batch-ecr`.
- `discovered_subnet_ids` merges and de-duplicates both subnet naming patterns.
- `effective_subnet_ids` prefers user-supplied subnet IDs.
- `effective_security_group_ids` prefers user-supplied security groups; otherwise it selects the module-created group.
- `container_environment` converts a Terraform map into the name/value objects expected by AWS Batch.
- `effective_container_image` prefers `container_image`; otherwise it builds `<repository_url>:<batch_image_tag>`.
- `standard_tags` records application ownership and deployment metadata.
- `tags` merges standard tags, then `additional_tags`, then `apprepo_tags`. Later maps win on duplicate keys.

### `variables.tf`

- Required identifiers define the application, account, compute environment, queue, and job definition.
- `compute_resource_type` is validated against `FARGATE`, `FARGATE_SPOT`, `EC2`, and `SPOT`.
- `max_vcpus` applies to all compute types.
- `min_vcpus` and `instance_types` are used only for EC2 and Spot.
- Empty `subnet_ids` activates auto-discovery.
- Empty `security_group_ids` creates the default security group.
- Empty `container_image` selects the dedicated ECR repository and `batch_image_tag`.
- `command` overrides the container image's Docker `CMD` when non-empty.
- `environment_variables` becomes the job definition's container environment.

### `main.tf`: ECR and logs

- `aws_ecr_repository.batch` creates the job-image repository.
- `scan_on_push = true` requests vulnerability scanning when images are pushed.
- `AES256` enables server-side encryption with an AWS-managed key.
- `aws_ecr_lifecycle_policy.batch` expires images beyond the most recent 30.
- `aws_cloudwatch_log_group.batch_logs` creates `/aws/batch/<job_definition_name>` and applies the selected retention period.

### `main.tf`: networking

- `aws_security_group.batch_compute` is created only when no security groups are supplied.
- It has no inbound rule by default.
- Its egress rule allows all outbound traffic. Tighten this in regulated environments.
- Private jobs need outbound access through NAT, or appropriate VPC endpoints such as ECR API, ECR DKR, S3, CloudWatch Logs, Secrets Manager, and SSM.

### `main.tf`: IAM

- `batch_service_role` trusts `batch.amazonaws.com` and receives `AWSBatchServiceRole`.
- `ecs_instance_role` exists only for EC2 and Spot, trusts EC2, and receives `AmazonEC2ContainerServiceforEC2Role`.
- `ecs_instance_profile` exposes that EC2 role to compute instances.
- `spot_fleet_role` exists only for `SPOT` and receives `AmazonEC2SpotFleetTaggingRole`.
- `ecs_task_execution_role` trusts ECS tasks and receives `AmazonECSTaskExecutionRolePolicy` so the agent can pull images and write logs.
- `batch_job_role` is assumed by the running container and carries application permissions.
- The inline job policy grants the requested Secrets Manager, SSM Parameter Store, `umb-*-data` S3, and RDS permissions.
- `CloudWatchFullAccess` is also attached as requested. This is broad and should eventually be replaced with a narrower policy.

### `main.tf`: Batch resources

- `aws_batch_compute_environment.compute_env` creates a managed, enabled compute environment.
- Fargate skips `min_vcpus`, `instance_types`, instance profile, Spot role, and EC2 allocation strategy by assigning `null`.
- EC2 and Spot use `BEST_FIT_PROGRESSIVE` allocation.
- The preconditions stop planning when no subnet is available, the supplied account is wrong, or the provider region differs from `aws_region`.
- `aws_batch_job_queue.job_queue` binds the queue to the compute environment at order `1`.
- `aws_batch_job_definition.job_definition` registers the image, command, environment, IAM roles, vCPU, memory, networking, and awslogs configuration.
- `retry_strategy.attempts = 1` means AWS Batch does not automatically retry a failed attempt. Increase it for retry-safe workloads.

### `outputs.tf`

Outputs expose the Batch resource ARNs/names, ECR details, actual image URI, job role ARN, and log group. Use these values from CI/CD or other Terraform modules.

## How to use

### 1. Add the module to Common_TF_Modules

Place this directory at a stable path such as:

```text
Common_TF_Modules/batch-infra
```

Create a Git tag for reusable releases, for example `v1.0.0`.

### 2. Call the module from an application repository

```hcl
provider "aws" {
  region = var.aws_region
}

module "batch" {
  source = "git::<COMMON_TF_MODULES_REPOSITORY>//batch-infra?ref=v1.0.0"

  app_short_name           = "myapp"
  env                      = var.env
  aws_account_number       = var.aws_account_number
  aws_region               = var.aws_region
  compute_environment_name = "myapp-compute-env"
  job_queue_name           = "myapp-job-queue"
  job_definition_name      = "myapp-job-def"

  application_owner_email = var.application_owner_email
  project_ritm            = var.project_ritm
  git_repo_name           = var.git_repo_name
  cmdb_id                 = var.cmdb_id
}
```

Use the real Git URL in place of `<COMMON_TF_MODULES_REPOSITORY>`.

### 3. Configure values

Copy `terraform.tfvars.example` to `terraform.tfvars` and replace every sample value. Do not commit account secrets. These variables are metadata, not AWS credentials.

### 4. Authenticate to AWS

In Windows Command Prompt, one option is:

```bat
set AWS_PROFILE=my-profile
aws sts get-caller-identity
```

The returned account must match `aws_account_number`. Your provider region must match `aws_region`.

### 5. Initialize and review

```bat
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
```

Review the plan, especially IAM policies, VPC, subnets, security groups, and resource names.

### 6. Deploy

```bat
terraform apply tfplan
terraform output
```

### 7. Build and push the default image

Retrieve the repository URL:

```bat
terraform output -raw batch_ecr_repository_url
```

Then authenticate Docker and push. Replace account and region values:

```bat
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-2.amazonaws.com
docker build -t myapp-batch:latest .
docker tag myapp-batch:latest 123456789012.dkr.ecr.us-east-2.amazonaws.com/myapp-batch-ecr:latest
docker push 123456789012.dkr.ecr.us-east-2.amazonaws.com/myapp-batch-ecr:latest
```

Push the image before submitting a job. Terraform creates the repository and job definition, but it does not build the container.

### 8. Submit a job

```bat
aws batch submit-job --job-name myapp-nightly --job-queue myapp-job-queue --job-definition myapp-job-def
```

For runtime command overrides:

```bat
aws batch submit-job --job-name myapp-nightly --job-queue myapp-job-queue --job-definition myapp-job-def --container-overrides command=python,run_job.py,--mode,nightly
```

### 9. Monitor

```bat
aws batch list-jobs --job-queue myapp-job-queue --job-status RUNNING
aws logs tail /aws/batch/myapp-job-def --follow
```

## Important operating notes

- Each module call creates one compute environment, one queue, and one job definition. For multiple isolated job pipelines, call the module multiple times with unique names.
- If multiple job definitions can share capacity, a future design can separate compute/queue resources from job definitions to avoid duplicating compute environments.
- Fargate CPU and memory values must be a supported AWS Fargate combination.
- Private Fargate jobs have public IP assignment disabled. NAT or VPC endpoints are therefore required for ECR image pulls and AWS API access.
- `container_image` can point to another ECR repository, but the module still creates its dedicated ECR repository because that resource is part of the stated module contract.
- Environment variables are stored in the job definition. Do not put secret values in `environment_variables`; retrieve secrets at runtime through Secrets Manager or SSM.
- The default IAM policy is intentionally consistent with the supplied specification but is broader than least privilege.
- ECR retains the newest 30 images regardless of tag status.

## Recommended production hardening

1. Replace `CloudWatchFullAccess` with explicit CloudWatch Logs actions scoped to the log group.
2. Replace wildcard Secrets Manager, SSM, and RDS resources with application-specific ARNs.
3. Replace `s3:*` with only the object and bucket actions the job requires.
4. Add KMS permissions and KMS encryption if repositories, logs, secrets, or parameters use customer-managed keys.
5. Add configurable retry attempts, job timeouts, ephemeral storage, secrets injection, and Linux parameters if workloads require them.
6. Add `prevent_destroy` or ECR deletion controls if image retention is operationally important.
