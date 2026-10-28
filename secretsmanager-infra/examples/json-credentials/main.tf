provider "aws" { region = "us-east-2" }
variable "db_username" { type = string; sensitive = true }
variable "db_password" { type = string; sensitive = true }
module "db_credentials" {
  source = "../../"
  secret_name             = "/myapp/prod/db/credentials"
  secret_description      = "Application database credentials"
  secret_value            = jsonencode({ username = var.db_username, password = var.db_password })
  recovery_window_in_days = 0
  app_short_name = "myapp"
  env = "prod"
  application_owner_email = "owner@example.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "CMDB001"
}
