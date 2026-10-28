provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  table_suffix = "catalog"
  hash_key = "item_id"
  attributes = [{ name = "item_id", type = "S" }]
  create_access_role = true
  caller_service_principal = "lambda.amazonaws.com"
  access_actions = ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchGetItem"]
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
