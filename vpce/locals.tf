locals {
  env_map={test="dev",dev="dev",qa="qa",prod="prod"}
  compliant_env=lookup(local.env_map,lower(var.env),lower(var.env))
  default_type=contains(["dynamodb","s3"],lower(var.vpce_service_type))?"Gateway":"Interface"
  default_service=var.vpce_service_name!=""?var.vpce_service_name:"com.amazonaws.${var.aws_region}.${var.vpce_service_type}"
  default_key=replace(lower(var.vpce_service_type),"-","_")
  effective_endpoints=!var.create_vpce_module?{}:(length(var.vpc_endpoints)>0?var.vpc_endpoints:{(local.default_key)={service_name=local.default_service,vpc_endpoint_type=local.default_type,private_dns_enabled=local.default_type=="Interface"}})
  endpoint_keys=keys(local.effective_endpoints)
  effective_primary_key=var.primary_vpce_key!=""?var.primary_vpce_key:(length(local.endpoint_keys)>0?local.endpoint_keys[0]:null)
  effective_apigw_key=var.apigw_source_vpce_key!=""?var.apigw_source_vpce_key:local.effective_primary_key
  interface_keys=[for k,e in local.effective_endpoints:k if e.vpc_endpoint_type=="Interface"]
  tags=merge({umbAppName=var.alb_short_name,umbEnvironment=local.compliant_env,umbApplicationOwner=var.application_owner_email,umbProjectRITM=var.project_ritm,umbGitRepository=var.git_repo_name,umbCMDBID=var.cmdb_id,ManagedBy="Terraform"},var.apprepo_tags)
  private_domain="api-internal.services.${local.compliant_env}.aws.umb.com"
  public_domain="api.${local.compliant_env}.umb.com"
}
