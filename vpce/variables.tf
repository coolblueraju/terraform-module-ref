variable "create_vpce_module" { description="Create endpoint resources."; type=bool; default=false }
variable "vpce_service_type" { description="Service suffix used by simple/default mode, e.g. dynamodb, s3, execute-api."; type=string; default="execute-api" }
variable "vpce_service_name" { description="Optional full service name override."; type=string; default="" }
variable "vpc_endpoints" {
  description="Advanced endpoint map. Empty activates simple/default mode when create_vpce_module is true."
  type=map(object({
    service_name        = string
    vpc_endpoint_type   = optional(string, "Interface")
    private_dns_enabled = optional(bool, false)
  }))
  default={}
  validation { condition=alltrue([for e in values(var.vpc_endpoints):contains(["Interface","Gateway"],e.vpc_endpoint_type)]); error_message="vpc_endpoint_type must be Interface or Gateway." }
}
variable "gateway_route_table_ids" { description="Route-table IDs used by Gateway endpoints."; type=list(string); default=[] }
variable "primary_vpce_key" { description="Endpoint key used by primary outputs. Empty selects the default/first endpoint."; type=string; default="" }
variable "apigw_source_vpce_key" { description="Endpoint key used for API Gateway SourceVpce policy/association logic."; type=string; default="" }
variable "create_apigw_custom_domains" { type=bool; default=false }
variable "private_cert_arn" { type=string; default=null }
variable "public_cert_arn" { type=string; default=null }
variable "aws_region" { type=string; default="us-east-2" }
variable "aws_account_number" { type=string; validation { condition=can(regex("^[0-9]{12}$",var.aws_account_number)); error_message="aws_account_number must be 12 digits." } }
variable "alb_short_name" { type=string }
variable "env" { type=string }
variable "application_owner_email" { type=string }
variable "project_ritm" { type=string }
variable "git_repo_name" { type=string }
variable "cmdb_id" { type=string }
variable "apprepo_tags" { type=map(string); default={} }
