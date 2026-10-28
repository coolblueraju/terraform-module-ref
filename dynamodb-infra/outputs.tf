output "table_name" { description = "DynamoDB table name."; value = aws_dynamodb_table.this.name }
output "table_arn" { description = "DynamoDB table ARN."; value = aws_dynamodb_table.this.arn }
output "table_id" { description = "DynamoDB table ID."; value = aws_dynamodb_table.this.id }
output "table_stream_arn" { description = "Stream ARN, null when streams are disabled."; value = var.stream_enabled ? aws_dynamodb_table.this.stream_arn : null }
output "table_stream_label" { description = "Stream label, null when streams are disabled."; value = var.stream_enabled ? aws_dynamodb_table.this.stream_label : null }
output "access_role_arn" { description = "IAM access role ARN, null when disabled."; value = var.create_access_role ? aws_iam_role.access[0].arn : null }
output "access_role_name" { description = "IAM access role name, null when disabled."; value = var.create_access_role ? aws_iam_role.access[0].name : null }
