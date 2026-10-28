provider "aws" { region = "us-east-2" }
variable "api_key" { type = string; sensitive = true }
variable "service_token" { type = string; sensitive = true }
locals {
  secrets = {
    api_key = { name = "/myapp/qa/api/key", value = var.api_key }
    token   = { name = "/myapp/qa/service/token", value = var.service_token }
  }
}
module "secrets" {
  for_each = local.secrets
  source   = "../../"
  secret_name  = each.value.name
  secret_value = each.value.value
  app_short_name = "myapp"
  env = "qa"
  application_owner_email = "owner@example.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "CMDB001"
}
