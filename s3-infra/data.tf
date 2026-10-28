data "aws_dynamodb_table" "dispatcher" { count=var.grant_dynamodb_access && var.dynamodb_table_name!=null ? 1:0; name=var.dynamodb_table_name }
