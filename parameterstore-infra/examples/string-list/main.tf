provider "aws" { region = "us-east-2" }
module "allowed_regions" {
  source = "../../"
  parameter_name  = "/myapp/qa/config/allowed-regions"
  parameter_type  = "StringList"
  parameter_value = "us-east-1,us-east-2"
  app_short_name = "myapp"
  env = "qa"
  application_owner_email = "owner@example.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "CMDB001"
}
