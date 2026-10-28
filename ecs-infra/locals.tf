locals {
  ecs_dynamodb_table_names = distinct(var.dynamodb_table_names)
  default_dynamodb_actions = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:UpdateItem","dynamodb:DeleteItem","dynamodb:Query","dynamodb:Scan","dynamodb:BatchGetItem","dynamodb:BatchWriteItem"]
  effective_dynamodb_actions = length(var.dynamodb_access_actions) > 0 ? var.dynamodb_access_actions : local.default_dynamodb_actions
}
