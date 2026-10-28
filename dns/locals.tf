locals {
  zone_suffix = var.environment == "dev" ? "dev.aws.umb.com" : var.environment == "qa" ? "qa.aws.umb.com" : "aws.umb.com"
  fqdn        = "${var.app_name}.${local.zone_suffix}"
  aws_record_type = var.record_type == "ALIAS" ? "A" : var.record_type
}
