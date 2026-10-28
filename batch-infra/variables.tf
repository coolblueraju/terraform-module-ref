variable "app_short_name" {
  description = "Short application name used in default resource naming."
  type        = string
}

variable "env" {
  description = "Deployment environment name."
  type        = string
}

variable "aws_account_number" {
  description = "AWS account number. Validated against the active caller unless validation is disabled."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_number))
    error_message = "aws_account_number must contain exactly 12 digits."
  }
}

variable "aws_region" {
  description = "AWS region in which resources are created."
  type        = string
  default     = "us-east-2"
}

variable "compute_environment_name" {
  description = "AWS Batch compute environment name."
  type        = string
}

variable "job_queue_name" {
  description = "AWS Batch job queue name."
  type        = string
}

variable "job_definition_name" {
  description = "AWS Batch job definition name."
  type        = string
}

variable "compute_resource_type" {
  description = "Batch compute type: FARGATE, FARGATE_SPOT, EC2, or SPOT."
  type        = string
  default     = "FARGATE"

  validation {
    condition     = contains(["FARGATE", "FARGATE_SPOT", "EC2", "SPOT"], var.compute_resource_type)
    error_message = "compute_resource_type must be FARGATE, FARGATE_SPOT, EC2, or SPOT."
  }
}

variable "max_vcpus" {
  description = "Maximum vCPUs for the compute environment."
  type        = number
  default     = 4
}

variable "min_vcpus" {
  description = "Minimum vCPUs for EC2 or SPOT compute environments."
  type        = number
  default     = 0
}

variable "instance_types" {
  description = "EC2 instance types for EC2 or SPOT compute environments."
  type        = list(string)
  default     = ["optimal"]
}

variable "subnet_ids" {
  description = "Subnet IDs. When empty, private subnets are auto-discovered in the default VPC."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs. When empty, the module creates a dedicated security group."
  type        = list(string)
  default     = []
}

variable "job_queue_priority" {
  description = "Job queue priority. Higher values have higher priority."
  type        = number
  default     = 1
}

variable "batch_ecr_repository_name" {
  description = "Optional name override for the dedicated ECR repository."
  type        = string
  default     = ""
}

variable "batch_image_tag" {
  description = "Image tag used with the module-created ECR repository."
  type        = string
  default     = "latest"
}

variable "container_image" {
  description = "Optional full container image URI. Overrides the module-created ECR image URI."
  type        = string
  default     = ""
}

variable "vcpus" {
  description = "vCPUs assigned to each job container."
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory in MiB assigned to each job container."
  type        = number
  default     = 2048
}

variable "command" {
  description = "Optional command override for the job container."
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Environment variables passed to the job container."
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days."
  type        = number
  default     = 7
}

variable "application_owner_email" {
  description = "Application owner email used for tagging."
  type        = string
}

variable "git_repo_name" {
  description = "Git repository name used for tagging."
  type        = string
}

variable "project_ritm" {
  description = "Project RITM number used for tagging."
  type        = string
}

variable "cmdb_id" {
  description = "Application CMDB ID used for tagging."
  type        = string
}

variable "additional_tags" {
  description = "Additional tags merged into all resources."
  type        = map(string)
  default     = {}
}

variable "apprepo_tags" {
  description = "Application repository tags merged last with highest precedence."
  type        = map(string)
  default     = {}
}
