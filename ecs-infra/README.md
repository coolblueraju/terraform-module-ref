# ecs-infra

Deployable reconstruction from the supplied v4.0.0 module specification. The wrapper calls `ecs/` for cluster resources and `ecs-service/` for the service stack, then optionally adds a second multi-table DynamoDB policy to the task role.

## Flow
`ecs/` creates `<app>-ecs`, Container Insights, ECS Exec KMS/logging, and Fargate/Fargate Spot capacity providers. `ecs-service/` discovers `<app>-ecr`, its latest image, `<alb_short_name>-alb`, the HTTPS:443 listener, default VPC, and private subnets. It creates roles, logs, SG, HTTPS target group, path listener rule, task definition, ECS service, and CPU autoscaling.

## Important behavior
- Workspaces must be exactly `test`, `qa`, or `prod`; they tag as `dev`, `qa`, `prod`.
- ECR and shared ALB are prerequisites and are discovered, not created.
- Latest ECR image digest is selected during Terraform refresh/plan.
- Service uses `force_new_deployment = true` and circuit-breaker rollback.
- Task logs use `skip_destroy = true`.
- ECS service ingress allows only the shared ALB SG on the container port.
- Target group is HTTPS:443 with IP targets and health check port equal to the container `port`.
- CPU autoscaling uses `ECSServiceAverageCPUUtilization`; despite the historic variable name `ALBAvgCPUPerTarget`, it is a CPU percentage target.
- When DynamoDB is enabled, both the service managed policy and the top-level inline policy grant table/index access, preserving the documented redundant behavior.

## Minimal deployment
Before Terraform, ensure `<app_short_name>-ecr` contains at least one image, `<alb_short_name>-alb` exists with HTTPS listener 443, the default VPC exists, and private subnets contain `private` in the Name tag.

```powershell
terraform init
terraform workspace select qa
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output task_role_name
```

For a new workspace use `terraform workspace new qa`.

## Line-by-line guide
### Top level
`locals.tf` de-duplicates DynamoDB table names and chooses default read/write actions when the caller leaves `dynamodb_access_actions=[]`. `data.tf` resolves each selected DynamoDB table. `main.tf` invokes both submodules and attaches `aws_iam_role_policy.ecs_dynamodb_access` to `module.ecsservice.task_role_name` when access is enabled and tables exist.

### ecs/
The KMS key encrypts ECS Exec CloudWatch session logs. The cluster enables Container Insights. Capacity providers contain both FARGATE and FARGATE_SPOT, with default weights 100 and 0 respectively.

### ecs-service/
Data lookups resolve the repository/latest image, ALB/listener, default VPC, and private subnets. The execution role gets `AmazonECSTaskExecutionRolePolicy` and `CloudWatchFullAccess`. The task role receives the application managed policy for common Secrets Manager, SSM, S3, and optional DynamoDB access. The task definition uses the latest ECR digest, `awslogs`, and caller environment variables. The service uses private subnets, the module SG, target group, ECS Exec, a deployment circuit breaker, and force-new-deployment. Application Auto Scaling tracks average ECS CPU.

## Security review items
`CloudWatchFullAccess` is broad and should eventually be narrowed. Secrets/SSM resource patterns must match your real common-resource naming. S3 actions have been scoped to the documented application data bucket. The dual DynamoDB policies are preserved for compatibility but should be consolidated in a future breaking revision.
