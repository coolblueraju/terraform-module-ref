variable "application_name" {
  description = "Application name used for the budget name and umbAppName cost filter."
  type        = string
  validation {
    condition     = length(trimspace(var.application_name)) > 0
    error_message = "application_name must not be empty."
  }
}

variable "application_support_group" {
  description = "Email address that receives the budget alert."
  type        = string
  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.application_support_group))
    error_message = "application_support_group must be a valid email address."
  }
}

variable "monthly_budget" {
  description = "Monthly budget limit in USD."
  type        = number
  validation {
    condition     = var.monthly_budget > 0
    error_message = "monthly_budget must be greater than zero."
  }
}

variable "application_owner_director" {
  description = "Application owner director metadata. Preserved for compatibility with the shared module contract."
  type        = string
}

variable "application_owner_email" {
  description = "Application owner email used for tagging."
  type        = string
}

variable "project_ritm" {
  description = "Project RITM number used for tagging."
  type        = string
}

variable "git_repo_name" {
  description = "Git repository name used for tagging."
  type        = string
}

variable "cmdb_id" {
  description = "Application CMDB ID used for tagging."
  type        = string
}

variable "env" {
  description = "Environment name used for tagging."
  type        = string
  validation {
    condition     = length(trimspace(var.env)) > 0
    error_message = "env must not be empty."
  }
}

variable "apprepo_tags" {
  description = "Additional app-repository tags merged last with highest precedence."
  type        = map(string)
  default     = {}
}
