resource "aws_ssm_parameter" "parameter" {
  name  = var.parameter_name
  type  = var.parameter_type
  value = var.parameter_value

  tags = local.tags
}
