data "aws_caller_identity" "current" {}
data "aws_vpc" "default" {
  filter { name = "tag:umbDefaultVPC" values = ["true"] }
  filter { name = "tag:umbEnvironment" values = [local.compliant_env] }
}
data "aws_subnets" "private" {
  filter { name = "vpc-id" values = [data.aws_vpc.default.id] }
  filter { name = "tag:Name" values = ["*private*"] }
}
data "aws_dynamodb_table" "target" {
  count = var.grant_dynamodb_access && var.dynamodb_table_name != null ? 1 : 0
  name  = var.dynamodb_table_name
}
