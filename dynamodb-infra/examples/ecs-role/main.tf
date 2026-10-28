provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  table_suffix = "sessions"
  hash_key = "session_id"
  attributes = [{ name = "session_id", type = "S" }]
  create_access_role = true
  caller_service_principal = "ecs-tasks.amazonaws.com"
  allowed_caller_role_arns = ["arn:aws:iam::123456789012:role/my-ecs-execution-role"]
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
