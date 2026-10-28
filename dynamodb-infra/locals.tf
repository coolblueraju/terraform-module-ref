locals {
  table_name = var.table_name_override != "" ? var.table_name_override : "${var.app_short_name}-${var.table_suffix}"

  default_access_actions = [
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem",
    "dynamodb:Query",
    "dynamodb:Scan",
    "dynamodb:BatchGetItem",
    "dynamodb:BatchWriteItem",
    "dynamodb:ConditionCheckItem"
  ]

  effective_access_actions = length(var.access_actions) > 0 ? var.access_actions : local.default_access_actions

  common_tags = {
    umbAppName          = var.app_short_name
    umbEnvironment      = var.env
    umbApplicationOwner = var.application_owner_email
    umbProjectRITM      = var.project_ritm
    umbGitRepository    = var.git_repo_name
    umbCMDBID           = var.cmdb_id
    ManagedBy           = "Terraform"
  }

  tags = merge(local.common_tags, var.additional_tags, var.apprepo_tags)

  attribute_names = toset([for attribute in var.attributes : attribute.name])
  gsi_key_names = toset(flatten([
    for index in var.global_secondary_indexes : compact([index.hash_key, try(index.range_key, "")])
  ]))
  required_key_names = setunion(toset(compact([var.hash_key, var.range_key])), local.gsi_key_names)
}
