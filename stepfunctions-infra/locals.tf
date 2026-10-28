locals {
  environment_tag_map = {
    test = "dev"
    qa   = "qa"
    prod = "prod"
  }
  compliant_env = lookup(local.environment_tag_map, terraform.workspace, null)

  placeholder_definition = jsonencode({
    Comment = "Placeholder workflow for ${var.app_short_name}"
    StartAt = "Placeholder"
    States = {
      Placeholder = {
        Type = "Pass"
        End  = true
      }
    }
  })

  effective_definition = var.state_machine_definition == null || trimspace(var.state_machine_definition) == "" ? local.placeholder_definition : var.state_machine_definition

  standard_tags = {
    umbAppName          = var.app_short_name
    umbEnvironment      = local.compliant_env
    umbApplicationOwner = var.application_owner_email
    umbGitRepository    = var.git_repo_name
    umbProjectRITM      = var.project_ritm
    umbCMDBID           = var.cmdb_id
    ManagedBy           = "Terraform"
  }

  tags = merge(local.standard_tags, var.additional_tags, var.apprepo_tags)
}
