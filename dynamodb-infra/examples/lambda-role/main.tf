provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  table_suffix = "events"
  hash_key = "event_id"
  attributes = [{ name = "event_id", type = "S" }]
  create_access_role = true
  caller_service_principal = "lambda.amazonaws.com"
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
