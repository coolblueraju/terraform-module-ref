variable "app_short_name" { type=string; validation { condition=length(trimspace(var.app_short_name))>0; error_message="app_short_name must not be empty." } }
variable "env" { type=string; validation { condition=contains(["dev","test","qa","prod"],lower(var.env)); error_message="env must be dev, test, qa, or prod." } }
variable "lambda_name" { type=string; validation { condition=length(trimspace(var.lambda_name))>0 && length(var.lambda_name)<=64; error_message="lambda_name must be 1-64 characters." } }
variable "lambda_zip_path" { type=string; validation { condition=endswith(lower(var.lambda_zip_path),".zip"); error_message="lambda_zip_path must point to a .zip deployment package." } }
variable "aws_region" { type=string; default="us-east-2" }
variable "handler" { type=string; default="index.handler" }
variable "runtime" {
  type=string; default="python3.9"
  validation { condition=contains(["python3.9","python3.10","python3.11","python3.12","nodejs16.x","nodejs18.x","nodejs20.x","java11","java17","java21","dotnet6","dotnet8","ruby3.2","ruby3.3","provided.al2023"],var.runtime); error_message="runtime is not in the module-supported runtime list." }
}
variable "timeout" { type=number; default=300; validation { condition=var.timeout>=1 && var.timeout<=900; error_message="timeout must be 1-900 seconds." } }
variable "memory_size" { type=number; default=512; validation { condition=var.memory_size>=128 && var.memory_size<=10240; error_message="memory_size must be 128-10240 MB." } }
variable "environment_variables" { type=map(string); default={} }
variable "log_retention_days" { type=number; default=7 }
variable "grant_dynamodb_access" { type=bool; default=false }
variable "dynamodb_table_name" { type=string; default=null }
variable "dynamodb_access_actions" { type=list(string); default=[] }
variable "dynamodb_allow_stream_read" { type=bool; default=false }
variable "dynamodb_stream_enabled" { type=bool; default=false }
variable "application_owner_email" { type=string }
variable "git_repo_name" { type=string }
variable "project_ritm" { type=string }
variable "cmdb_id" { type=string }
variable "apprepo_tags" { type=map(string); default={} }
variable "additional_security_group_rules" {
  type=list(object({ type=string, from_port=number, to_port=number, protocol=string, cidr_blocks=optional(list(string),[]), source_security_group_id=optional(string) }))
  default=[]
  validation { condition=alltrue([for r in var.additional_security_group_rules:contains(["ingress","egress"],r.type)]); error_message="additional_security_group_rules type must be ingress or egress." }
}
