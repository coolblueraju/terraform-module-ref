resource "aws_cloudwatch_log_group" "sfn_logs" {
  name              = "/aws/states/${var.state_machine_name}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

resource "aws_iam_role" "sfn_role" {
  name = substr("${var.state_machine_name}-role", 0, 64)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "sfn_logs_policy" {
  name = substr("${var.state_machine_name}-logs-policy", 0, 128)
  role = aws_iam_role.sfn_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_sfn_state_machine" "state_machine" {
  name       = var.state_machine_name
  role_arn   = aws_iam_role.sfn_role.arn
  type       = var.type
  definition = local.effective_definition

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn_logs.arn}:*"
    include_execution_data = false
    level                  = "ERROR"
  }

  lifecycle {
    precondition {
      condition     = local.compliant_env != null
      error_message = "terraform.workspace must be test, qa, or prod."
    }
  }

  tags = local.tags

  depends_on = [aws_iam_role_policy.sfn_logs_policy]
}
