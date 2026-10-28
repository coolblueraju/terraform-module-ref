provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  table_suffix = "orders"
  hash_key = "order_id"
  attributes = [{ name = "order_id", type = "S" }]
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
