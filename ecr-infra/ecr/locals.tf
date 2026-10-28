locals {
  ecr_name = "${var.app_short_name}-ecr"

  environment_tag_map = {
    test = "dev"
    qa   = "qa"
    prod = "prod"
  }

  compliant_env = lookup(local.environment_tag_map, terraform.workspace, null)

  common_tags = {
    umbAppName          = var.app_short_name
    umbEnvironment      = local.compliant_env
    umbApplicationOwner = var.application_owner_email
    umbProjectRITM      = var.project_ritm
    umbGitRepository    = var.git_repo_name
    umbCMDBID           = var.cmdb_id
    ManagedBy           = "Terraform"
  }

  tags = merge(local.common_tags, var.apprepo_tags)
}
