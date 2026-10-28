resource "aws_dynamodb_table" "this" {
  name         = local.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key != "" ? var.range_key : null

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  deletion_protection_enabled = var.deletion_protection_enabled
  stream_enabled              = var.stream_enabled
  stream_view_type            = var.stream_enabled ? var.stream_view_type : null

  dynamic "attribute" {
    for_each = { for item in var.attributes : item.name => item }
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key != "" ? global_secondary_index.value.range_key : null
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
      read_capacity      = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  lifecycle {
    precondition {
      condition     = length(setsubtract(local.required_key_names, local.attribute_names)) == 0
      error_message = "attributes must define the table hash/range keys and every GSI hash/range key."
    }
    precondition {
      condition = var.billing_mode != "PROVISIONED" || (
        var.read_capacity != null && var.write_capacity != null && var.read_capacity > 0 && var.write_capacity > 0
      )
      error_message = "PROVISIONED billing requires positive read_capacity and write_capacity."
    }
    precondition {
      condition = var.billing_mode != "PROVISIONED" || alltrue([
        for g in var.global_secondary_indexes : g.read_capacity != null && g.write_capacity != null && g.read_capacity > 0 && g.write_capacity > 0
      ])
      error_message = "Every GSI requires positive read_capacity and write_capacity in PROVISIONED mode."
    }
    precondition {
      condition     = !var.ttl_enabled || length(trimspace(var.ttl_attribute)) > 0
      error_message = "ttl_attribute is required when ttl_enabled is true."
    }
  }

  tags = local.tags
}

resource "aws_iam_role" "access" {
  count = var.create_access_role ? 1 : 0
  name  = "pe-${var.app_short_name}-dynamodb-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      var.caller_service_principal != "" ? [{ Effect = "Allow", Principal = { Service = var.caller_service_principal }, Action = "sts:AssumeRole" }] : [],
      length(var.allowed_caller_role_arns) > 0 ? [{ Effect = "Allow", Principal = { AWS = var.allowed_caller_role_arns }, Action = "sts:AssumeRole" }] : []
    )
  })

  lifecycle {
    precondition {
      condition = !var.create_access_role || (
        length(trimspace(var.caller_service_principal)) > 0 || length(var.allowed_caller_role_arns) > 0
      )
      error_message = "create_access_role requires caller_service_principal or at least one allowed_caller_role_arn."
    }
  }

  tags = local.tags
}

resource "aws_iam_role_policy" "access" {
  count = var.create_access_role ? 1 : 0
  name  = "pe-${var.app_short_name}-dynamodb-access-policy"
  role  = aws_iam_role.access[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [{
        Sid      = "TableAccess"
        Effect   = "Allow"
        Action   = local.effective_access_actions
        Resource = [aws_dynamodb_table.this.arn, "${aws_dynamodb_table.this.arn}/index/*"]
      }],
      var.allow_stream_read ? [{
        Sid    = "StreamRead"
        Effect = "Allow"
        Action = ["dynamodb:GetRecords", "dynamodb:GetShardIterator", "dynamodb:DescribeStream", "dynamodb:ListStreams"]
        Resource = var.stream_enabled ? [aws_dynamodb_table.this.stream_arn] : []
      }] : []
    )
  })

  lifecycle {
    precondition {
      condition     = !var.allow_stream_read || var.stream_enabled
      error_message = "allow_stream_read requires stream_enabled = true."
    }
  }
}
