module "ecs" {
  source = "./ecs"
  app_short_name = var.app_short_name
  env = var.env
  application_owner_email = var.application_owner_email
  project_ritm = var.project_ritm
  git_repo_name = var.git_repo_name
  cmdb_id = var.cmdb_id
  apprepo_tags = var.apprepo_tags
}

module "ecsservice" {
  source = "./ecs-service"
  app_short_name = var.app_short_name
  env = var.env
  alb_short_name = var.alb_short_name
  health_check_path = var.health_check_path
  port = var.port
  memory = var.memory
  cpu = var.cpu
  max_capacity = var.max_capacity
  min_capacity = var.min_capacity
  ALBAvgCPUPerTarget = var.ALBAvgCPUPerTarget
  lister_rule_uri_pattern = var.lister_rule_uri_pattern
  env_vars = var.env_vars
  aws_region = var.aws_region
  grant_dynamodb_access = var.grant_dynamodb_access
  dynamodb_table_names = local.ecs_dynamodb_table_names
  dynamodb_access_actions = length(var.dynamodb_access_actions) > 0 ? var.dynamodb_access_actions : local.default_dynamodb_actions
  application_owner_email = var.application_owner_email
  project_ritm = var.project_ritm
  git_repo_name = var.git_repo_name
  cmdb_id = var.cmdb_id
  apprepo_tags = var.apprepo_tags
}

resource "aws_iam_role_policy" "ecs_dynamodb_access" {
  count = var.grant_dynamodb_access && length(local.ecs_dynamodb_table_names) > 0 ? 1 : 0
  name  = "${var.app_short_name}-ecs-dynamodb-access"
  role  = module.ecsservice.task_role_name
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = local.effective_dynamodb_actions, Resource = flatten([for t in data.aws_dynamodb_table.ecs_tables : [t.arn, "${t.arn}/index/*"]]) }] })
}
