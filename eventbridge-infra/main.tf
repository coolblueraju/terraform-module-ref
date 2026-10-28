resource "aws_cloudwatch_event_rule" "rule" {
  name                = var.rule_name
  description         = var.description
  schedule_expression = var.schedule_expression
  event_pattern       = var.event_pattern
  state               = var.enabled ? "ENABLED" : "DISABLED"

  lifecycle {
    precondition {
      condition = (var.schedule_expression != null) != (var.event_pattern != null)
      error_message = "Exactly one of schedule_expression or event_pattern must be supplied."
    }
    precondition {
      condition = var.event_pattern == null || can(jsondecode(var.event_pattern))
      error_message = "event_pattern must contain valid JSON."
    }
    precondition {
      condition = local.normalized_target_type != "lambda" || length(trimspace(var.target_lambda_name)) > 0
      error_message = "target_lambda_name is required when target_type = lambda."
    }
    precondition {
      condition = local.normalized_target_type != "step_functions" || length(trimspace(var.target_state_machine_name)) > 0
      error_message = "target_state_machine_name is required when target_type = step_functions."
    }
  }

  tags = local.tags
}

resource "aws_iam_role" "eventbridge_invoke_sfn_role" {
  count = local.requires_role ? 1 : 0
  name  = substr("${var.rule_name}-events-role", 0, 64)
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "events.amazonaws.com" }, Action = "sts:AssumeRole" }] })
  tags = local.tags
}

resource "aws_iam_role_policy" "eventbridge_start_execution" {
  count = local.requires_role ? 1 : 0
  name  = substr("${var.rule_name}-start-sfn", 0, 128)
  role  = aws_iam_role.eventbridge_invoke_sfn_role[0].id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = ["states:StartExecution"], Resource = local.state_machine_arn }] })
}

resource "aws_cloudwatch_event_target" "target" {
  rule     = aws_cloudwatch_event_rule.rule.name
  arn      = local.target_arn
  role_arn = local.requires_role ? aws_iam_role.eventbridge_invoke_sfn_role[0].arn : null
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count         = local.normalized_target_type == "lambda" ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge-${substr(md5(var.rule_name), 0, 8)}"
  action        = "lambda:InvokeFunction"
  function_name = var.target_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule.arn
}
