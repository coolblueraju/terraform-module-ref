output "secret_name" {
  description = "Name of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.secret.name
}
output "secret_arn" {
  description = "ARN of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.secret.arn
}
output "secret_id" {
  description = "ID of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.secret.id
}
output "secret_version_id" {
  description = "Version ID of the current Terraform-managed secret value."
  value       = aws_secretsmanager_secret_version.secret_version.version_id
}
