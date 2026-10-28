output "ecr_repo_url" {
  description = "Repository URL of the created ECR repository."
  value       = aws_ecr_repository.ecr.repository_url
}
