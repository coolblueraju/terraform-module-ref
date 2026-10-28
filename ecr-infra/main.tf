module "ecr" {
  source = "./ecr"

  app_short_name          = var.app_short_name
  env                     = var.env
  application_owner_email = var.application_owner_email
  project_ritm            = var.project_ritm
  git_repo_name           = var.git_repo_name
  cmdb_id                 = var.cmdb_id
  apprepo_tags            = var.apprepo_tags
}
