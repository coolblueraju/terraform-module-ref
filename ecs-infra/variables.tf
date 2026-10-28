variable "app_short_name" { type = string; validation { condition = length(trimspace(var.app_short_name)) > 0; error_message = "app_short_name must not be empty." } }
variable "env" { type = string }
variable "alb_short_name" { type = string }
variable "health_check_path" { type = string }
variable "port" { type = number; validation { condition = var.port > 0 && var.port <= 65535; error_message = "port must be 1-65535." } }
variable "memory" { type = string }
variable "cpu" { type = string }
variable "max_capacity" { type = number }
variable "min_capacity" { type = number }
variable "ALBAvgCPUPerTarget" { type = number; validation { condition = var.ALBAvgCPUPerTarget > 0 && var.ALBAvgCPUPerTarget <= 100; error_message = "ALBAvgCPUPerTarget must be > 0 and <= 100." } }
variable "lister_rule_uri_pattern" { type = string }
variable "env_vars" { type = map(string) }
variable "application_owner_email" { type = string }
variable "project_ritm" { type = string }
variable "git_repo_name" { type = string }
variable "cmdb_id" { type = string }
variable "aws_region" { type = string; default = "us-east-2" }
variable "grant_dynamodb_access" { type = bool; default = false }
variable "dynamodb_table_names" { type = list(string); default = [] }
variable "dynamodb_access_actions" { type = list(string); default = [] }
variable "apprepo_tags" { type = map(string); default = {} }
