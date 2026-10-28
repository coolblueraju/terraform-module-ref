provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "prod"
  table_suffix = "sensitive-records"
  hash_key = "record_id"
  attributes = [{ name = "record_id", type = "S" }]
  kms_key_arn = "arn:aws:kms:us-east-2:123456789012:key/mrk-abc123"
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
