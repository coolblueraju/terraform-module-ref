locals {
  is_fargate         = contains(["FARGATE", "FARGATE_SPOT"], var.compute_resource_type)
  platform_capability = local.is_fargate ? "FARGATE" : "EC2"

  effective_ecr_repository_name = var.batch_ecr_repository_name != "" ? var.batch_ecr_repository_name : "${var.app_short_name}-batch-ecr"

  discovered_subnet_ids = distinct(concat(
    data.aws_subnets.private_pattern_one.ids,
    data.aws_subnets.private_pattern_two.ids
  ))

  effective_subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : local.discovered_subnet_ids

  effective_security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.batch_compute[0].id]

  container_environment = [
    for key, value in var.environment_variables : {
      name  = key
      value = value
    }
  ]

  effective_container_image = var.container_image != "" ? var.container_image : "${aws_ecr_repository.batch.repository_url}:${var.batch_image_tag}"

  standard_tags = {
    Application        = var.app_short_name
    Environment        = var.env
    ApplicationOwner   = var.application_owner_email
    ProjectRITM        = var.project_ritm
    GitRepository      = var.git_repo_name
    CMDBID             = var.cmdb_id
    ManagedBy          = "Terraform"
  }

  tags = merge(local.standard_tags, var.additional_tags, var.apprepo_tags)
}
