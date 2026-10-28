provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "prod"
  table_suffix = "orders"
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5
  hash_key = "order_id"
  attributes = [{ name = "order_id", type = "S" }, { name = "status", type = "S" }]
  global_secondary_indexes = [{ name = "status-index", hash_key = "status", projection_type = "ALL", read_capacity = 5, write_capacity = 5 }]
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
