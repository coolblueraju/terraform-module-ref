locals {
  environment_tag_map = { test="dev", qa="qa", prod="prod" }
  compliant_env = lookup(local.environment_tag_map, terraform.workspace, null)
  cluster_name = "${var.app_short_name}-ecs"
  service_name = "${var.app_short_name}-svc"
  sg_name = "${var.app_short_name}-svc-sg"
  target_group_name = "${var.app_short_name}-tg"
  ecr_name = "${var.app_short_name}-ecr"
  alb_name = "${var.alb_short_name}-alb"
  data_bucket_name = "umb-${var.app_short_name}-${var.env}-${var.aws_region}-data"
  env_list = [for k,v in var.env_vars : { name=k, value=v }]
  tags = merge({ umbAppName=var.app_short_name, umbEnvironment=local.compliant_env, umbApplicationOwner=var.application_owner_email, umbProjectRITM=var.project_ritm, umbGitRepository=var.git_repo_name, umbCMDBID=var.cmdb_id }, var.apprepo_tags)
}
