provider "aws" { region = "us-east-2" }
variable "api_key" { type = string; sensitive = true }
module "api_key" {
  source = "../../"
  secret_name        = "/myapp/dev/third-party/api-key"
  secret_description = "Third-party API key"
  secret_value       = var.api_key
  app_short_name = "myapp"
  env = "dev"
  application_owner_email = "owner@example.com"
  project_ritm = "RITM0012345"
  git_repo_name = "myapp-infra"
  cmdb_id = "CMDB001"
}
