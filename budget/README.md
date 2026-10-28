# budget

Reusable Terraform module for creating an AWS Budgets monthly COST budget scoped by the `umbAppName` cost-allocation tag, with an ACTUAL-spend email alert at 80%.

## Files

- `versions.tf`: Terraform and AWS provider requirements.
- `variables.tf`: module inputs plus validation.
- `main.tf`: common tags and the AWS Budgets resource.
- `outputs.tf`: budget name, ID, amount, and threshold.
- `examples/basic`: minimal complete example.
- `examples/custom-tags`: example with `apprepo_tags`.

## Line-by-line guide

### versions.tf

`terraform {` opens Terraform settings. `required_version = ">= 1.5.0"` establishes the minimum Terraform CLI version. `required_providers` declares dependencies. `source = "hashicorp/aws"` uses the official AWS provider, while `version = ">= 5.0"` sets the provider floor.

### variables.tf

`application_name` supplies both the `<application_name>-mbudget` name prefix and the `umbAppName` filter value. It cannot be blank.

`application_support_group` is the email recipient. A validation checks the basic email shape.

`monthly_budget` is numeric USD budget capacity and must be greater than zero.

`application_owner_director` is retained because it is part of the supplied Common_TF_Modules interface. The supplied specification says it is metadata only, so it is intentionally not applied to the budget resource.

`application_owner_email`, `project_ritm`, `git_repo_name`, `cmdb_id`, and `env` populate common tags.

`apprepo_tags` defaults to `{}`. Because it is merged last, duplicate keys here override common tags.

### main.tf locals

`common_tags` builds the standard application metadata map. `tags = merge(local.common_tags, var.apprepo_tags)` creates the final tag set.

### main.tf budget

`aws_budgets_budget.application_budget_monthly` creates one budget. `name` becomes `myapp-mbudget` when `application_name = "myapp"`. `budget_type = "COST"` selects a cost budget. `limit_amount` is the configured monthly amount. `limit_unit = "USD"` sets US dollars. `time_unit = "MONTHLY"` resets the measurement period monthly.

The `cost_filter` uses AWS Budgets `TagKeyValue` syntax. For `application_name = "myapp"`, the value becomes `umbAppName$myapp`. Cost allocation tags must be available for billing data or the expected application spend will not be represented.

The `cost_types` block explicitly includes credits, discounts, subscriptions, recurring costs, refunds, support, tax, and upfront costs. It leaves amortized and blended cost disabled to preserve the supplied behavior.

The `notification` block uses `GREATER_THAN`, an 80 `PERCENTAGE` threshold, and `ACTUAL` cost. For a $500 monthly budget, 80% is $400. The only subscriber is `application_support_group`.

`tags = local.tags` applies the merged metadata to the budget.

### outputs.tf

`budget_name` and `budget_id` expose the created object. `monthly_budget` exposes the configured amount. `notification_threshold_percentage` records the module's fixed 80% behavior.

## Common_TF_Modules usage

```hcl
module "budget" {
  source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/budget/?ref=v4.0.0"

  application_name           = "myapp"
  application_support_group  = "myapp-support@umb.com"
  monthly_budget             = 500
  application_owner_director = "Jane Director"
  application_owner_email    = var.application_owner_email
  project_ritm               = var.project_ritm
  git_repo_name              = var.git_repo_name
  cmdb_id                    = var.cmdb_id
  env                        = var.env
}
```

Do not copy HTML anchor markup into `source`; it must be a plain Terraform Git source string.

## Deploy from PowerShell

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Worked example

With a monthly budget of `$500`, the fixed 80% threshold corresponds to `$400`. The notification is based on ACTUAL cost rather than FORECASTED cost.

## Important prerequisites

Cost filtering depends on AWS billing seeing the `umbAppName` tag. Confirm your organization's cost-allocation-tag configuration and allow for AWS billing/tag propagation before treating an empty or incomplete budget as a Terraform defect.

## Design constraints retained from the supplied module

- One monthly COST budget per module call.
- Fixed 80% ACTUAL-cost alert.
- One subscriber email input.
- USD currency.
- `time_period_start` is not explicitly set.
- `application_owner_director` is accepted but does not affect the resource.

## Recommended future enhancements

For a future major version, consider variables for threshold, multiple notifications/subscribers, FORECASTED alerts, cost types, and currency. Those are deliberately not added here because they would change the supplied module contract.
