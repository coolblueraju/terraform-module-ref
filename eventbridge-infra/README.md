# eventbridge-infra

Reusable Terraform module for one EventBridge rule and one Lambda or Step Functions target.

## Files
- `versions.tf`: Terraform/AWS provider requirements.
- `variables.tf`: module inputs and validations.
- `locals.tf`: environment normalization, target ARN construction, target selection, role requirement, and tags.
- `main.tf`: rule, optional Step Functions IAM role/policy, target binding, and optional Lambda permission.
- `outputs.tf`: rule name and ARN.
- `examples/`: scheduled Step Functions and event-pattern Lambda examples.

## Line-by-line guide
### Rule
`aws_cloudwatch_event_rule.rule` receives the caller's `rule_name` unchanged. Exactly one of `schedule_expression` and `event_pattern` must be configured. `enabled` translates to EventBridge state `ENABLED` or `DISABLED`. A precondition verifies JSON when an event pattern is supplied.

### Target selection
`target_type` is lowercased. For `step_functions`, the module constructs `arn:aws:states:<region>:<account>:stateMachine:<name>`. For `lambda`, it constructs `arn:aws:lambda:<region>:<account>:function:<name>`. These are intentionally constructed rather than looked up, preserving the supplied contract, so Terraform cannot prove the named target exists before EventBridge attempts to use it.

### Step Functions IAM
For a Step Functions target only, `<rule_name>-events-role` is created and truncated to the IAM role 64-character limit. Its trust policy permits `events.amazonaws.com`. The inline `<rule_name>-start-sfn` policy grants only `states:StartExecution` on the constructed state-machine ARN. The EventBridge target receives this role ARN.

### Lambda permission
For Lambda, no EventBridge execution role is created. `aws_lambda_permission.allow_eventbridge` adds a Lambda resource-based permission for `events.amazonaws.com`, scoped by `source_arn` to this rule.

### Safety validation
The module fails early when both scheduling inputs are set, neither is set, event-pattern JSON is malformed, or the target-specific name is missing.

## Common_TF_Modules usage
Use a plain Terraform source string:
```hcl
source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/eventbridge-infra/?ref=v4.0.0"
```
Do not paste HTML anchor markup into HCL.

## PowerShell deployment
```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Operational notes
1. One module call creates one rule and one target.
2. Target ARNs are constructed from names and are not data-source validated.
3. For scheduled rules, use valid EventBridge `rate(...)` or `cron(...)` syntax.
4. For event-pattern rules, validate the actual emitting service event shape. An S3 EventBridge rule also depends on S3/EventBridge integration being configured appropriately for the event source.
5. Lambda permission is rule-scoped by `source_arn`; Step Functions uses a dedicated least-privilege invocation role.
