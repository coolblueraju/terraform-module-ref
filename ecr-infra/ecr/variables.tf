variable "app_short_name" { description = "Application short name."; type = string }
variable "env" { description = "Compatibility environment input; workspace controls environment tag."; type = string }
variable "application_owner_email" { description = "Owner email tag."; type = string }
variable "project_ritm" { description = "Project RITM tag."; type = string }
variable "git_repo_name" { description = "Git repository tag."; type = string }
variable "cmdb_id" { description = "CMDB ID tag."; type = string }
variable "apprepo_tags" { description = "Additional app-repository tags."; type = map(string); default = {} }
variable "encrypt_type" {
  description = "ECR encryption type. Top-level wrapper intentionally does not expose this input."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encrypt_type)
    error_message = "encrypt_type must be AES256 or KMS."
  }
}
