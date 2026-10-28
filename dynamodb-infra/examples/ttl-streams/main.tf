provider "aws" { region = "us-east-2" }

module "dynamodb" {
  source = "../../"
  app_short_name = "myapp"
  env = "qa"
  table_suffix = "metadata"
  hash_key = "partition_key"
  range_key = "sort_key"
  attributes = [{ name = "partition_key", type = "S" }, { name = "sort_key", type = "S" }]
  ttl_enabled = true
  ttl_attribute = "ttl_epoch"
  point_in_time_recovery = true
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  create_access_role = true
  caller_service_principal = "lambda.amazonaws.com"
  allow_stream_read = true
  application_owner_email = "owner@umb.com"
  project_ritm            = "RITM0012345"
  git_repo_name           = "myapp-infra"
  cmdb_id                 = "APP-001234"
}
