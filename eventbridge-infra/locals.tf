locals {
  environment_tag_map = { test = "dev", dev = "dev", qa = "qa", prod = "prod" }
  compliant_env       = lookup(local.environment_tag_map, lower(var.env), lower(var.env))
  normalized_target_type = lower(var.target_type)
  state_machine_arn = "arn:aws:states:${var.aws_region}:${var.aws_account_number}:stateMachine:${var.target_state_machine_name}"
  lambda_arn        = "arn:aws:lambda:${var.aws_region}:${var.aws_account_number}:function:${var.target_lambda_name}"
  target_arn        = local.normalized_target_type == "lambda" ? local.lambda_arn : local.state_machine_arn
  requires_role     = local.normalized_target_type == "step_functions"
  standard_tags = {
    umbAppName          = var.app_short_name
    umbEnvironment      = local.compliant_env
    umbApplicationOwner = var.application_owner_email
    umbProjectRITM      = var.project_ritm
    umbGitRepository    = var.git_repo_name
    umbCMDBID           = var.cmdb_id
    ManagedBy           = "Terraform"
  }
  tags = merge(local.standard_tags, var.additional_tags, var.apprepo_tags)
}
