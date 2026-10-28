provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  hash_key = "pk"
  range_key = "sk"
  attributes = [{ name = "pk", type = "S" }, { name = "sk", type = "S" }]
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
