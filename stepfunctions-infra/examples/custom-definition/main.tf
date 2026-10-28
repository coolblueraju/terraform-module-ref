provider "aws" { region = "us-east-2" }

module "sfn" {
  source = "../../"

  app_short_name     = "myapp"
  env                = "prod"
  aws_region         = "us-east-2"
  aws_account_number = "123456789012"

  state_machine_name       = "myapp-batch-sfn"
  type                     = "STANDARD"
  state_machine_definition = file("${path.module}/statemachine/definition.asl.json")
  log_retention_days       = 30

  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
