provider "aws" { region = "us-east-2" }
module "eventbridge" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  aws_region = "us-east-2"
  aws_account_number = "123456789012"
  rule_name = "myapp-s3-upload-rule"
  event_pattern = jsonencode({ source = ["aws.s3"], detail-type = ["Object Created"] })
  target_type = "lambda"
  target_lambda_name = "myapp-processor"
  application_owner_email = "owner@umb.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "APP-001234"
}
