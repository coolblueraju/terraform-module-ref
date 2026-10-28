locals {
  common_tags = {
    umbAppName          = var.application_name
    umbEnvironment      = var.env
    umbApplicationOwner = var.application_owner_email
    umbProjectRITM      = var.project_ritm
    umbGitRepository    = var.git_repo_name
    umbCMDBID           = var.cmdb_id
  }

  tags = merge(local.common_tags, var.apprepo_tags)
}

resource "aws_budgets_budget" "application_budget_monthly" {
  name         = "${var.application_name}-mbudget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["umbAppName$${var.application_name}"]
  }

  cost_types {
    include_credit             = true
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = true
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_amortized              = false
    use_blended                = false
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.application_support_group]
  }

  tags = local.tags
}
