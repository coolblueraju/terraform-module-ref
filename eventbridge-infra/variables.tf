variable "app_short_name" {
  description = "Application short name used in tagging."
  type = string
  validation { condition = length(trimspace(var.app_short_name)) > 0; error_message = "app_short_name must not be empty." }
}
variable "env" {
  description = "Environment name. Common values: test, qa, prod."
  type = string
  validation { condition = length(trimspace(var.env)) > 0; error_message = "env must not be empty." }
}
variable "aws_account_number" {
  description = "AWS account number used to construct target ARNs."
  type = string
  validation { condition = can(regex("^[0-9]{12}$", var.aws_account_number)); error_message = "aws_account_number must contain exactly 12 digits." }
}
variable "aws_region" { description = "AWS region used to construct target ARNs."; type = string; default = "us-east-2" }
variable "rule_name" {
  description = "EventBridge rule name."
  type = string
  validation { condition = length(trimspace(var.rule_name)) > 0 && length(var.rule_name) <= 64; error_message = "rule_name must be 1-64 characters." }
}
variable "description" { description = "EventBridge rule description."; type = string; default = "" }
variable "schedule_expression" { description = "Optional cron(...) or rate(...) expression. Mutually exclusive with event_pattern."; type = string; default = null }
variable "event_pattern" { description = "Optional JSON event pattern. Mutually exclusive with schedule_expression."; type = string; default = null }
variable "enabled" { description = "Whether the rule is enabled."; type = bool; default = true }
variable "target_type" {
  description = "Target type: step_functions or lambda."
  type = string
  default = "step_functions"
  validation { condition = contains(["step_functions", "lambda"], lower(var.target_type)); error_message = "target_type must be step_functions or lambda." }
}
variable "target_state_machine_name" { description = "State machine name required for Step Functions targets."; type = string; default = "" }
variable "target_lambda_name" { description = "Lambda function name required for Lambda targets."; type = string; default = "" }
variable "application_owner_email" { description = "Owner email used for tagging."; type = string }
variable "git_repo_name" { description = "Git repository name used for tagging."; type = string }
variable "project_ritm" { description = "Project RITM used for tagging."; type = string }
variable "cmdb_id" { description = "Application CMDB ID used for tagging."; type = string }
variable "additional_tags" { description = "Additional tags merged after standard tags."; type = map(string); default = {} }
variable "apprepo_tags" { description = "Application repository tags merged last with highest precedence."; type = map(string); default = {} }
