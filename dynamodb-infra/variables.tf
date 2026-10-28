variable "app_short_name" {
  description = "Short application name used in resource naming."
  type        = string
  validation {
    condition     = length(trimspace(var.app_short_name)) > 0
    error_message = "app_short_name must not be empty."
  }
}
variable "env" {
  description = "Environment name: test, qa, or prod."
  type        = string
  validation {
    condition     = contains(["test", "qa", "prod"], lower(var.env))
    error_message = "env must be test, qa, or prod."
  }
}
variable "hash_key" {
  description = "Partition key attribute name."
  type        = string
  validation {
    condition     = length(trimspace(var.hash_key)) > 0
    error_message = "hash_key must not be empty."
  }
}
variable "range_key" { description = "Optional sort key attribute name."; type = string; default = "" }
variable "attributes" {
  description = "Attribute definitions for table and index keys."
  type = list(object({ name = string, type = string }))
  validation {
    condition     = alltrue([for a in var.attributes : contains(["S", "N", "B"], a.type)])
    error_message = "Each attribute type must be S, N, or B."
  }
}
variable "table_suffix" { description = "Suffix appended to app_short_name."; type = string; default = "table" }
variable "table_name_override" { description = "Optional full table name override."; type = string; default = "" }
variable "billing_mode" {
  description = "PAY_PER_REQUEST or PROVISIONED."
  type = string
  default = "PAY_PER_REQUEST"
  validation {
    condition = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}
variable "read_capacity" { description = "Table read capacity for PROVISIONED mode."; type = number; default = null }
variable "write_capacity" { description = "Table write capacity for PROVISIONED mode."; type = number; default = null }
variable "ttl_enabled" { description = "Enable TTL."; type = bool; default = false }
variable "ttl_attribute" { description = "TTL attribute name."; type = string; default = "" }
variable "point_in_time_recovery" { description = "Enable PITR."; type = bool; default = false }
variable "stream_enabled" { description = "Enable DynamoDB Streams."; type = bool; default = false }
variable "stream_view_type" {
  description = "DynamoDB stream view type."
  type = string
  default = "NEW_AND_OLD_IMAGES"
  validation {
    condition = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "stream_view_type must be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}
variable "kms_key_arn" { description = "Optional customer-managed KMS key ARN."; type = string; default = "" }
variable "deletion_protection_enabled" { description = "Enable DynamoDB deletion protection."; type = bool; default = true }
variable "global_secondary_indexes" {
  description = "Global secondary index definitions."
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string, "")
    projection_type = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
    read_capacity   = optional(number)
    write_capacity  = optional(number)
  }))
  default = []
  validation {
    condition = alltrue([for g in var.global_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], g.projection_type)])
    error_message = "GSI projection_type must be ALL, KEYS_ONLY, or INCLUDE."
  }
}
variable "create_access_role" { description = "Create an IAM access role."; type = bool; default = false }
variable "caller_service_principal" { description = "Service principal trusted by the access role."; type = string; default = "" }
variable "allowed_caller_role_arns" { description = "Additional IAM role ARNs trusted by the access role."; type = list(string); default = [] }
variable "access_actions" { description = "DynamoDB actions granted by the role. Empty uses module defaults."; type = list(string); default = [] }
variable "allow_stream_read" { description = "Grant stream read permissions."; type = bool; default = false }
variable "application_owner_email" { description = "Owner email tag."; type = string }
variable "project_ritm" { description = "Project RITM tag."; type = string }
variable "git_repo_name" { description = "Git repository tag."; type = string }
variable "cmdb_id" { description = "CMDB ID tag."; type = string }
variable "additional_tags" { description = "Additional tags."; type = map(string); default = {} }
variable "apprepo_tags" { description = "App-repository tags merged last."; type = map(string); default = {} }
