output "parameter_name" {
  description = "Name of the SSM parameter."
  value       = aws_ssm_parameter.parameter.name
}
output "parameter_arn" {
  description = "ARN of the SSM parameter."
  value       = aws_ssm_parameter.parameter.arn
}
output "parameter_version" {
  description = "Current version of the SSM parameter."
  value       = aws_ssm_parameter.parameter.version
}
