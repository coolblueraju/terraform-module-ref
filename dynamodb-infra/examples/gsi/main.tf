provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  table_suffix = "users"
  hash_key = "user_id"
  range_key = "created_at"
  attributes = [{ name = "user_id", type = "S" }, { name = "created_at", type = "S" }, { name = "email", type = "S" }]
  global_secondary_indexes = [{ name = "email-index", hash_key = "email", projection_type = "ALL" }]
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
