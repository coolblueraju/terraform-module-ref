variable "app_short_name" {
  description = "Application name used for tagging and placeholder definition metadata."
  type        = string
  validation {
    condition     = length(trimspace(var.app_short_name)) > 0
    error_message = "app_short_name must not be empty."
  }
}
variable "env" {
  description = "Environment name. Workspace controls the compliant environment tag."
  type        = string
  validation {
    condition     = length(trimspace(var.env)) > 0
    error_message = "env must not be empty."
  }
}
variable "aws_account_number" {
  description = "AWS account number retained for compatibility with the module contract."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_number))
    error_message = "aws_account_number must contain exactly 12 digits."
  }
}
variable "aws_region" { description = "AWS region."; type = string; default = "us-east-2" }
variable "state_machine_name" {
  description = "Name of the Step Functions state machine."
  type        = string
  validation {
    condition     = length(trimspace(var.state_machine_name)) > 0 && length(var.state_machine_name) <= 80
    error_message = "state_machine_name must be 1-80 characters."
  }
}
variable "type" {
  description = "Step Functions workflow type."
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "EXPRESS"], var.type)
    error_message = "type must be STANDARD or EXPRESS."
  }
}
variable "log_retention_days" {
  description = "CloudWatch Logs retention in days."
  type        = number
  default     = 7
  validation {
    condition     = var.log_retention_days > 0
    error_message = "log_retention_days must be greater than zero."
  }
}
variable "state_machine_definition" {
  description = "Amazon States Language JSON definition. Null or empty uses the placeholder Pass workflow."
  type        = string
  default     = null
  validation {
    condition     = var.state_machine_definition == null || trimspace(var.state_machine_definition) == "" || can(jsondecode(var.state_machine_definition))
    error_message = "state_machine_definition must be valid JSON when supplied."
  }
}
variable "application_owner_email" { description = "Owner email used for tagging."; type = string }
variable "git_repo_name" { description = "Git repository name used for tagging."; type = string }
variable "project_ritm" { description = "Project RITM used for tagging."; type = string }
variable "cmdb_id" { description = "Application CMDB ID used for tagging."; type = string }
variable "additional_tags" { description = "Additional tags merged after standard tags."; type = map(string); default = {} }
variable "apprepo_tags" { description = "App-repository tags merged last with highest precedence."; type = map(string); default = {} }
