data "aws_dynamodb_table" "ecs_tables" {
  for_each = var.grant_dynamodb_access ? toset(local.ecs_dynamodb_table_names) : toset([])
  name     = each.value
}
