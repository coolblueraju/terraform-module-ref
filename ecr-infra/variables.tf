variable "app_short_name" {
  description = "Application short name used to build the ECR repository name."
  type        = string
  validation {
    condition     = length(trimspace(var.app_short_name)) > 0
    error_message = "app_short_name must not be empty."
  }
}
variable "env" {
  description = "Environment name accepted for compatibility. Resource environment tagging follows terraform.workspace per the supplied contract."
  type        = string
  validation {
    condition     = length(trimspace(var.env)) > 0
    error_message = "env must not be empty."
  }
}
variable "application_owner_email" { description = "Owner email used for tagging."; type = string }
variable "project_ritm" { description = "Project RITM used for tagging."; type = string }
variable "git_repo_name" { description = "Git repository name used for tagging."; type = string }
variable "cmdb_id" { description = "Application CMDB ID used for tagging."; type = string }
variable "apprepo_tags" { description = "Additional app-repository tags merged last with highest precedence."; type = map(string); default = {} }
