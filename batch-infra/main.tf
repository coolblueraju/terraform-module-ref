resource "aws_ecr_repository" "batch" {
  name                 = local.effective_ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "batch" {
  repository = aws_ecr_repository.batch.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the 30 most recent images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 30
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_cloudwatch_log_group" "batch_logs" {
  name              = "/aws/batch/${var.job_definition_name}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

resource "aws_security_group" "batch_compute" {
  count = length(var.security_group_ids) == 0 ? 1 : 0

  name        = "${var.compute_environment_name}-sg"
  description = "Security group for ${var.compute_environment_name}"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "Allow outbound connectivity"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.compute_environment_name}-sg" })
}

resource "aws_iam_role" "batch_service_role" {
  name = "${var.compute_environment_name}-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "batch.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "batch_service_role" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role" "spot_fleet_role" {
  count = var.compute_resource_type == "SPOT" ? 1 : 0
  name  = "${var.compute_environment_name}-spot-fleet-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "spotfleet.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "spot_fleet_role" {
  count      = var.compute_resource_type == "SPOT" ? 1 : 0
  role       = aws_iam_role.spot_fleet_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "aws_iam_role" "ecs_instance_role" {
  count = local.is_fargate ? 0 : 1
  name  = "${var.compute_environment_name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  count      = local.is_fargate ? 0 : 1
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  count = local.is_fargate ? 0 : 1
  name  = "${var.compute_environment_name}-ecs-instance-profile"
  role  = aws_iam_role.ecs_instance_role[0].name
  tags  = local.tags
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.compute_environment_name}-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "batch_job_role" {
  name = "${var.job_definition_name}-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "batch_job_role_policy" {
  name = "${var.job_definition_name}-job-policy"
  role = aws_iam_role.batch_job_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadSecrets"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "*"
      },
      {
        Sid      = "ReadParameters"
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
        Resource = "*"
      },
      {
        Sid      = "UseApplicationDataBuckets"
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = ["arn:aws:s3:::umb-*-data", "arn:aws:s3:::umb-*-data/*"]
      },
      {
        Sid      = "ConnectAndDescribeDatabases"
        Effect   = "Allow"
        Action   = ["rds-db:connect", "rds:DescribeDBInstances", "rds:DescribeDBClusters"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_job_cloudwatch" {
  role       = aws_iam_role.batch_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_batch_compute_environment" "compute_env" {
  compute_environment_name = var.compute_environment_name
  service_role             = aws_iam_role.batch_service_role.arn
  type                     = "MANAGED"
  state                    = "ENABLED"

  compute_resources {
    type               = var.compute_resource_type
    max_vcpus          = var.max_vcpus
    min_vcpus          = local.is_fargate ? null : var.min_vcpus
    instance_types     = local.is_fargate ? null : var.instance_types
    instance_role      = local.is_fargate ? null : aws_iam_instance_profile.ecs_instance_profile[0].arn
    spot_iam_fleet_role = var.compute_resource_type == "SPOT" ? aws_iam_role.spot_fleet_role[0].arn : null
    allocation_strategy = local.is_fargate ? null : "BEST_FIT_PROGRESSIVE"
    subnets            = local.effective_subnet_ids
    security_group_ids = local.effective_security_group_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.batch_service_role,
    aws_iam_role_policy_attachment.ecs_instance_role,
    aws_iam_role_policy_attachment.spot_fleet_role
  ]

  lifecycle {
    precondition {
      condition     = length(local.effective_subnet_ids) > 0
      error_message = "No subnets were found. Supply subnet_ids or use the documented private-subnet Name tag convention."
    }

    precondition {
      condition     = var.aws_account_number == data.aws_caller_identity.current.account_id
      error_message = "aws_account_number does not match the active AWS caller account."
    }

    precondition {
      condition     = var.aws_region == data.aws_region.current.name
      error_message = "aws_region does not match the AWS provider region."
    }
  }

  tags = local.tags
}

resource "aws_batch_job_queue" "job_queue" {
  name     = var.job_queue_name
  state    = "ENABLED"
  priority = var.job_queue_priority

  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.compute_env.arn
  }

  tags = local.tags
}

resource "aws_batch_job_definition" "job_definition" {
  name                  = var.job_definition_name
  type                  = "container"
  platform_capabilities = [local.platform_capability]

  container_properties = jsonencode({
    image            = local.effective_container_image
    command          = length(var.command) > 0 ? var.command : null
    jobRoleArn       = aws_iam_role.batch_job_role.arn
    executionRoleArn = aws_iam_role.ecs_task_execution_role.arn
    environment      = local.container_environment
    resourceRequirements = [
      { type = "VCPU", value = tostring(var.vcpus) },
      { type = "MEMORY", value = tostring(var.memory) }
    ]
    networkConfiguration = local.is_fargate ? { assignPublicIp = "DISABLED" } : null
    fargatePlatformConfiguration = local.is_fargate ? { platformVersion = "LATEST" } : null
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.batch_logs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "batch"
      }
    }
  })

  retry_strategy {
    attempts = 1
  }

  tags = local.tags
}
