output "compute_environment_arn" {
  description = "ARN of the Batch compute environment."
  value       = aws_batch_compute_environment.compute_env.arn
}

output "compute_environment_name" {
  description = "Name of the Batch compute environment."
  value       = aws_batch_compute_environment.compute_env.compute_environment_name
}

output "batch_ecr_repository_name" {
  description = "Name of the dedicated ECR repository."
  value       = aws_ecr_repository.batch.name
}

output "batch_ecr_repository_arn" {
  description = "ARN of the dedicated ECR repository."
  value       = aws_ecr_repository.batch.arn
}

output "batch_ecr_repository_url" {
  description = "URL of the dedicated ECR repository."
  value       = aws_ecr_repository.batch.repository_url
}

output "effective_container_image" {
  description = "Container image URI used by the job definition."
  value       = local.effective_container_image
}

output "job_queue_arn" {
  description = "ARN of the Batch job queue."
  value       = aws_batch_job_queue.job_queue.arn
}

output "job_queue_name" {
  description = "Name of the Batch job queue."
  value       = aws_batch_job_queue.job_queue.name
}

output "job_definition_arn" {
  description = "ARN and revision of the Batch job definition."
  value       = aws_batch_job_definition.job_definition.arn
}

output "job_definition_name" {
  description = "Name of the Batch job definition."
  value       = aws_batch_job_definition.job_definition.name
}

output "batch_job_role_arn" {
  description = "ARN of the IAM role used by job containers."
  value       = aws_iam_role.batch_job_role.arn
}

output "log_group_name" {
  description = "CloudWatch log group used by Batch jobs."
  value       = aws_cloudwatch_log_group.batch_logs.name
}
