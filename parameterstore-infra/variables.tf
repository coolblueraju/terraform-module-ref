variable "parameter_name" {
  description = "Full SSM parameter name/path, for example /app/dev/db/password."
  type        = string
  validation {
    condition     = length(trimspace(var.parameter_name)) > 0 && startswith(var.parameter_name, "/")
    error_message = "parameter_name must be a non-empty absolute SSM path beginning with /."
  }
}
variable "parameter_value" {
  description = "Value stored in SSM Parameter Store. Note that Terraform state still contains this value."
  type        = string
  sensitive   = true
}
variable "parameter_type" {
  description = "SSM parameter type: String, StringList, or SecureString."
  type        = string
  validation {
    condition     = contains(["String", "StringList", "SecureString"], var.parameter_type)
    error_message = "parameter_type must be String, StringList, or SecureString."
  }
}
variable "app_short_name" {
  description = "Application short name used for tagging."
  type        = string
  validation {
    condition     = length(trimspace(var.app_short_name)) > 0
    error_message = "app_short_name must not be empty."
  }
}
variable "env" {
  description = "Environment value used directly in the umbEnvironment tag."
  type        = string
  validation {
    condition     = length(trimspace(var.env)) > 0
    error_message = "env must not be empty."
  }
}
variable "application_owner_email" { description = "Application owner email used for tagging."; type = string }
variable "project_ritm" { description = "Project RITM used for tagging."; type = string }
variable "git_repo_name" { description = "Git repository name used for tagging."; type = string }
variable "cmdb_id" { description = "Application CMDB ID used for tagging."; type = string }
