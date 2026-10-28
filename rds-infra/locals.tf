locals {
  environment_tag_map = { test="dev", qa="qa", prod="prod" }
  compliant_env = lookup(local.environment_tag_map, terraform.workspace, null)
  rds_user_parameter = "${var.rds_short_name}-rds-user"
  rds_password_parameter = "${var.rds_short_name}-rds-password"
  instance_size = element(split(".",var.instance_class),length(split(".",var.instance_class))-1)
  subnet_ids = distinct(concat(data.aws_subnets.private_pattern_one.ids,data.aws_subnets.private_pattern_two.ids))
  selected_subnet_ids = slice(local.subnet_ids,0,min(2,length(local.subnet_ids)))
  tags = merge({umbAppName=var.rds_short_name,umbEnvironment=local.compliant_env,umbApplicationOwner=var.application_owner_email,umbProjectRITM=var.project_ritm,umbGitRepository=var.git_repo_name,umbCMDBID=var.cmdb_id,ManagedBy="Terraform"},var.apprepo_tags)
}
