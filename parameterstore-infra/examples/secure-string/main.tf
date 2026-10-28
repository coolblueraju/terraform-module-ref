provider "aws" { region = "us-east-2" }
variable "db_password" { type = string; sensitive = true }
module "db_password" {
  source = "../../"
  parameter_name  = "/myapp/prod/db/password"
  parameter_type  = "SecureString"
  parameter_value = var.db_password
  app_short_name = "myapp"
  env = "prod"
  application_owner_email = "owner@example.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "CMDB001"
}
