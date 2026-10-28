variable "rds_short_name" { type=string; validation { condition=length(trimspace(var.rds_short_name))>0; error_message="rds_short_name must not be empty." } }
variable "instance_class" { type=string; validation { condition=startswith(var.instance_class,"db."); error_message="instance_class must start with db." } }
variable "engine_version" { type=string }
variable "dbparametergroupFamily" { type=string }
variable "env" { type=string }
variable "shared_buffers_by_size" { type=map(string) }
variable "effective_cache_size_by_size" { type=map(string) }
variable "work_mem_by_size" { type=map(string) }
variable "application_owner_email" { type=string }
variable "project_ritm" { type=string }
variable "git_repo_name" { type=string }
variable "cmdb_id" { type=string }
variable "aws_region" { type=string; default="us-east-2" }
variable "port" { type=number; default=8432; validation { condition=var.port>0 && var.port<=65535; error_message="port must be 1-65535." } }
variable "rdsinbound_ip_ranges" { type=map(object({cidr=string,description=string})); default={} }
variable "apprepo_tags" { type=map(string); default={} }
