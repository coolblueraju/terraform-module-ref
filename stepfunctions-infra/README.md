# stepfunctions-infra

Reusable Terraform module creating one Step Functions state machine, its execution role, and CloudWatch execution logging.

## Files
- `versions.tf`: Terraform/AWS provider requirements.
- `variables.tf`: public inputs and validation.
- `locals.tf`: workspace mapping, placeholder ASL, effective definition, tags.
- `main.tf`: log group, role, logging IAM policy, state machine.
- `outputs.tf`: state-machine ARN/name, role ARN, log-group name.
- `examples/placeholder`: bootstrap workflow.
- `examples/custom-definition`: file-based Amazon States Language definition.

## Line-by-line guide

### Workspace/tagging
`terraform.workspace` is mapped as `test -> dev`, `qa -> qa`, and `prod -> prod`. Unsupported workspaces fail before state-machine creation. `additional_tags` are merged after standard tags and `apprepo_tags` are merged last, so app-repository tags have highest precedence.

### Placeholder definition
When `state_machine_definition` is null or empty, `local.placeholder_definition` creates one `Pass` state called `Placeholder`. This is infrastructure scaffolding only, not a production workflow.

### Log group
`aws_cloudwatch_log_group.sfn_logs` creates `/aws/states/<state_machine_name>` and uses the configurable retention period.

### Execution role
`aws_iam_role.sfn_role` trusts `states.amazonaws.com`. Its name is truncated to the IAM role limit. This role deliberately has no Lambda, Batch, ECS, S3, DynamoDB, EventBridge, or other workflow-task permissions.

### Logging policy
The inline logging policy contains the CloudWatch Logs delivery actions Step Functions needs for execution logging. These log-delivery APIs use `Resource = "*"` because the service APIs are not meaningfully restricted to the log-group ARN in the same way as ordinary PutLogEvents permissions.

### State machine
`aws_sfn_state_machine.state_machine` uses the requested `STANDARD` or `EXPRESS` type and `local.effective_definition`. Logging is fixed to `ERROR` with `include_execution_data = false`, matching the supplied module behavior. The log destination uses the Step Functions-required `:<asterisk>` suffix on the log-group ARN.

## Add task permissions from the caller
A real workflow typically needs actions such as:
- `lambda:InvokeFunction`
- `batch:SubmitJob`
- `ecs:RunTask`
- `states:StartExecution`
- `dynamodb:GetItem` / `PutItem`

This module does not guess those permissions. Use `state_machine_role_arn` to compose an application-specific IAM policy in the caller or extend the shared module with a controlled policy-statements input.

## Common_TF_Modules usage
Use plain HCL:
```hcl
source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/stepfunctions-infra/?ref=v4.0.0"
```

## Deploy from PowerShell
```powershell
terraform init
terraform workspace select qa
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Production cautions
1. Replace the placeholder definition before production.
2. Keep task permissions least-privilege and aligned to the ASL definition.
3. `ERROR` logging is intentionally sparse. During investigation you may temporarily need `ALL`, but `include_execution_data=true` can expose sensitive workflow inputs/outputs.
4. `aws_account_number` and `aws_region` are retained for compatibility even though this implementation does not use them to construct workflow resources.
