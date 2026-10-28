provider "aws" { region = "us-east-2" }
locals {
  parameters = {
    log_level = { name = "/myapp/dev/config/log-level", value = "INFO" }
    feature_x = { name = "/myapp/dev/feature/x-enabled", value = "true" }
  }
}
module "parameters" {
  for_each = local.parameters
  source   = "../../"
  parameter_name  = each.value.name
  parameter_type  = "String"
  parameter_value = each.value.value
  app_short_name = "myapp"
  env = "dev"
  application_owner_email = "owner@example.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "CMDB001"
}
