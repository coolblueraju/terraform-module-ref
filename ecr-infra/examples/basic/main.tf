provider "aws" { region = "us-east-2" }

module "ecr" {
  source = "../../"

  app_short_name          = "myapp"
  env                     = "test"
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
