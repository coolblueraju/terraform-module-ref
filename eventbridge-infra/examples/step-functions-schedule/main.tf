provider "aws" { region = "us-east-2" }
module "eventbridge" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  aws_region = "us-east-2"
  aws_account_number = "123456789012"
  rule_name = "myapp-nightly-rule"
  description = "Triggers the nightly batch state machine"
  schedule_expression = "cron(0 6 * * ? *)"
  target_type = "step_functions"
  target_state_machine_name = "myapp-batch-sfn"
  application_owner_email = "owner@umb.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "APP-001234"
}
