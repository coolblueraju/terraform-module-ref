resource "aws_kms_key" "kms_key" { description = "ECS Exec logs for ${local.cluster_name}"; enable_key_rotation = true; tags = local.tags }
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" { name = "${var.app_short_name}-ecs-logs"; retention_in_days = 30; tags = local.tags }
resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.cluster_name
  setting { name = "containerInsights"; value = "enabled" }
  configuration { execute_command_configuration { kms_key_id = aws_kms_key.kms_key.arn; logging = "OVERRIDE"; log_configuration { cloud_watch_encryption_enabled = true; cloud_watch_log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name } } }
  lifecycle { precondition { condition = local.compliant_env != null; error_message = "terraform.workspace must be test, qa, or prod." } }
  tags = local.tags
}
resource "aws_ecs_cluster_capacity_providers" "fargate_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy { capacity_provider = "FARGATE"; weight = 100; base = 1 }
  default_capacity_provider_strategy { capacity_provider = "FARGATE_SPOT"; weight = 0 }
}
