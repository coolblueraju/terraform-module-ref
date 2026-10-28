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
  container_image          = "123456789012.dkr.ecr.us-east-2.amazonaws.com/myapp-batch:v1.2.3"
  command                  = ["python", "run_job.py", "--mode", "nightly"]
  environment_variables = {
    STAGE     = var.env
    LOG_LEVEL = "INFO"
  }
  application_owner_email = var.application_owner_email
  project_ritm            = var.project_ritm
  git_repo_name           = var.git_repo_name
  cmdb_id                 = var.cmdb_id
}
