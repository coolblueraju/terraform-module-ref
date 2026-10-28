locals {
  environment_tag_map = { dev = "dev", test = "dev", qa = "qa", prod = "prod" }
  compliant_env = lookup(local.environment_tag_map, lower(var.env), lower(var.env))
  default_dynamodb_actions = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:DeleteItem","dynamodb:Query","dynamodb:Scan","dynamodb:BatchGetItem","dynamodb:BatchWriteItem"]
  effective_dynamodb_actions = length(var.dynamodb_access_actions) > 0 ? var.dynamodb_access_actions : local.default_dynamodb_actions
  log_group_name = "/aws/lambda/${var.lambda_name}"
  tags = merge({ umbAppName=var.app_short_name, umbEnvironment=local.compliant_env, umbApplicationOwner=var.application_owner_email, umbGitRepository=var.git_repo_name, umbProjectRITM=var.project_ritm, umbCMDBID=var.cmdb_id, ManagedBy="Terraform" }, var.apprepo_tags)
}
