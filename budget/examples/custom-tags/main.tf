provider "aws" {
  region = "us-east-2"
}

module "budget" {
  source = "../../"

  application_name           = "myapp"
  application_support_group  = "myapp-support@umb.com"
  monthly_budget             = 1000
  application_owner_director = "Jane Director"
  application_owner_email    = "owner@umb.com"
  project_ritm               = "RITM0012345"
  git_repo_name              = "myapp-infra"
  cmdb_id                    = "APP-001234"
  env                        = "prod"

  apprepo_tags = {
    ManagedBy  = "Terraform"
    CostCenter = "12345"
  }
}
