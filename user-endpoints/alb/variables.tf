variable "alb_short_name" { type=string }; variable "env" { type=string }; variable "cert_arn" { type=string }
variable "alb_type" { type=string; default="internal"; validation { condition=contains(["public","private","internal"],var.alb_type); error_message="alb_type must be public, private, or internal." } }
variable "trusted_ip_ranges" { type=map(object({cidr=string,description=string})); default={} }
variable "enable_mtls" { type=bool; default=false }; variable "mtls_mode" { type=string; default="verify"; validation { condition=contains(["off","passthrough","verify"],var.mtls_mode); error_message="mtls_mode must be off, passthrough, or verify." } }
variable "mtls_create_trust_store" { type=bool; default=false }; variable "mtls_trust_store_s3_bucket" { type=string; default=null }; variable "mtls_trust_store_s3_bucket_path" { type=string; default=null }
variable "vpce_eni_ips" { type=list(string); default=null }
variable "internal_alb_pass_through_target_groups" { type=list(object({tg_short_name=string,targets=list(object({ip=string,availability_zone=string}))})); default=[] }
variable "application_owner_email" { type=string }; variable "project_ritm" { type=string }; variable "git_repo_name" { type=string }; variable "cmdb_id" { type=string }; variable "apprepo_tags" { type=map(string); default={} }
