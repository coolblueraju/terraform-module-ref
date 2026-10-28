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
  compute_resource_type    = "EC2"
  instance_types           = ["m5.large", "m5.xlarge"]
  min_vcpus                = 0
  max_vcpus                = 16
  job_queue_name           = "myapp-job-queue"
  job_definition_name      = "myapp-job-def"
  vcpus                    = 2
  memory                   = 4096
  application_owner_email  = var.application_owner_email
  project_ritm             = var.project_ritm
  git_repo_name            = var.git_repo_name
  cmdb_id                  = var.cmdb_id
}
