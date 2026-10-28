provider "aws" {
  region = var.aws_region
}

module "batch" {
  source = "../../"

  app_short_name           = "myapp"
  env                      = var.env
  aws_account_number       = var.aws_account_number
  aws_region               = var.aws_region
  compute_environment_name = "myapp-compute-env"
  job_queue_name           = "myapp-job-queue"
  job_definition_name      = "myapp-job-def"
  subnet_ids               = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  security_group_ids       = ["sg-0123456789abcdef0"]
  application_owner_email  = var.application_owner_email
  project_ritm             = var.project_ritm
  git_repo_name            = var.git_repo_name
  cmdb_id                  = var.cmdb_id
}
