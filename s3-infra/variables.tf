variable "app_short_name" { type=string; validation { condition=length(trimspace(var.app_short_name))>0; error_message="app_short_name must not be empty." } }
variable "env" { type=string; validation { condition=length(trimspace(var.env))>0; error_message="env must not be empty." } }
variable "bucket_name" { type=string; validation { condition=length(var.bucket_name)>=3 && length(var.bucket_name)<=63; error_message="bucket_name must be 3-63 characters." } }
variable "aws_region" { type=string; default="us-east-2" }
variable "versioning_enabled" { type=bool; default=true }
variable "enable_encryption" { type=bool; default=true }
variable "kms_key_id" { type=string; default=null }
variable "block_public_access" { type=bool; default=true }
variable "enable_logging" { type=bool; default=false }
variable "logging_target_bucket" { type=string; default=null }
variable "logging_target_prefix" { type=string; default="logs/" }
variable "lifecycle_rules" {
  type=list(object({id=string,enabled=bool,prefix=optional(string,""),expiration_days=optional(number),noncurrent_version_expiration=optional(number),transition_glacier_days=optional(number)})); default=[]
}
variable "bucket_policy" { type=string; default=null }
variable "enable_object_lock" { type=bool; default=false }
variable "object_lock_mode" { type=string; default="GOVERNANCE"; validation { condition=contains(["GOVERNANCE","COMPLIANCE"],var.object_lock_mode); error_message="object_lock_mode must be GOVERNANCE or COMPLIANCE." } }
variable "object_lock_days" { type=number; default=1; validation { condition=var.object_lock_days>0; error_message="object_lock_days must be positive." } }
variable "force_destroy" { type=bool; default=false }
variable "additional_tags" { type=map(string); default={} }
variable "enable_event_notification" { type=bool; default=false }
variable "lambda_function_arn" { type=string; default=null }
variable "event_notification_filter_prefix" { type=string; default="" }
variable "event_notification_filter_suffix" { type=string; default="" }
variable "event_types" { type=list(string); default=["s3:ObjectCreated:*"] }
variable "grant_dynamodb_access" { type=bool; default=false }
variable "dynamodb_table_name" { type=string; default=null }
variable "dynamodb_access_actions" { type=list(string); default=[] }
variable "dispatcher_lambda_role_name" { type=string; default=null }
