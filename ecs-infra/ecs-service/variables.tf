variable "app_short_name" { type = string }
variable "env" { type = string }
variable "alb_short_name" { type = string }
variable "health_check_path" { type = string }
variable "port" { type = number }
variable "memory" { type = string }
variable "cpu" { type = string }
variable "max_capacity" { type = number }
variable "min_capacity" { type = number }
variable "ALBAvgCPUPerTarget" { type = number }
variable "lister_rule_uri_pattern" { type = string }
variable "env_vars" { type = map(string) }
variable "aws_region" { type = string; default = "us-east-2" }
variable "grant_dynamodb_access" { type = bool; default = false }
variable "dynamodb_table_names" { type = list(string); default = [] }
variable "dynamodb_access_actions" { type = list(string); default = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:DeleteItem","dynamodb:Query","dynamodb:Scan","dynamodb:BatchGetItem","dynamodb:BatchWriteItem"] }
variable "application_owner_email" { type = string }
variable "project_ritm" { type = string }
variable "git_repo_name" { type = string }
variable "cmdb_id" { type = string }
variable "apprepo_tags" { type = map(string); default = {} }
