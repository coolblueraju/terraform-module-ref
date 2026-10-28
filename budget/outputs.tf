output "budget_name" {
  description = "Name of the monthly AWS budget."
  value       = aws_budgets_budget.application_budget_monthly.name
}

output "budget_id" {
  description = "ID of the AWS budget."
  value       = aws_budgets_budget.application_budget_monthly.id
}

output "monthly_budget" {
  description = "Configured monthly budget in USD."
  value       = var.monthly_budget
}

output "notification_threshold_percentage" {
  description = "Actual-cost notification threshold percentage."
  value       = 80
}
