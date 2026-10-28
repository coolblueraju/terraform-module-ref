locals {
  tags = {
    umbAppName          = var.app_short_name
    umbEnvironment      = var.env
    umbApplicationOwner = var.application_owner_email
    umbProjectRITM      = var.project_ritm
    umbGitRepository    = var.git_repo_name
    umbCMDBID           = var.cmdb_id
    ManagedBy           = "Terraform"
  }
}
