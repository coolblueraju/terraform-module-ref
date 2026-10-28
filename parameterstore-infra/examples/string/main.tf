provider "aws" { region = "us-east-2" }
module "feature_flag" {
  source = "../../"
  parameter_name  = "/myapp/dev/feature/new-ui-enabled"
  parameter_type  = "String"
  parameter_value = "true"
  app_short_name = "myapp"
  env = "dev"
  application_owner_email = "owner@example.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "CMDB001"
}
