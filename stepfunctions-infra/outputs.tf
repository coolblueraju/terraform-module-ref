output "state_machine_arn" {
  description = "ARN of the Step Functions state machine."
  value       = aws_sfn_state_machine.state_machine.arn
}
output "state_machine_name" {
  description = "Name of the Step Functions state machine."
  value       = aws_sfn_state_machine.state_machine.name
}
output "state_machine_role_arn" {
  description = "ARN of the Step Functions execution role."
  value       = aws_iam_role.sfn_role.arn
}
output "log_group_name" {
  description = "CloudWatch log group for Step Functions execution logs."
  value       = aws_cloudwatch_log_group.sfn_logs.name
}
