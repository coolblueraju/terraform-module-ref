variable "secret_name" {
  description = "Secrets Manager secret name/path."
  type        = string
  validation {
    condition     = length(trimspace(var.secret_name)) > 0
    error_message = "secret_name must not be empty."
  }
}
variable "secret_value" {
  description = "Secret value, either a plain string or JSON-encoded string. Terraform state will contain this value."
  type        = string
  sensitive   = true
}
variable "secret_description" {
  description = "Description of the secret."
  type        = string
  default     = ""
}
variable "recovery_window_in_days" {
  description = "0 for immediate deletion or 7-30 days for a recovery window."
  type        = number
  default     = 30
  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "recovery_window_in_days must be 0 or between 7 and 30 inclusive."
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
  description = "Environment value used directly for tagging."
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
