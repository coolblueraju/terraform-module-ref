variable "alb_short_name" { type=string; validation { condition=length(trimspace(var.alb_short_name))>0; error_message="alb_short_name must not be empty." } }
variable "env" { type=string }
variable "cert_arn" { type=string; validation { condition=startswith(var.cert_arn,"arn:aws:acm:"); error_message="cert_arn must be an ACM certificate ARN." } }
variable "nlb_staticips" { type=list(string) }
variable "nlb_trusted_ip_ranges" { type=map(object({cidr=string,description=string})) }
variable "create_nlb_module" { type=bool; default=false }
variable "alb_trusted_ip_ranges" { type=map(object({cidr=string,description=string})); default={} }
variable "application_owner_email" { type=string }
variable "project_ritm" { type=string }
variable "git_repo_name" { type=string }
variable "cmdb_id" { type=string }
variable "apprepo_tags" { type=map(string); default={} }
