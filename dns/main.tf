resource "aws_route53_record" "dns_record" {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = local.fqdn
  type    = local.aws_record_type
  ttl     = var.record_type == "ALIAS" ? null : var.ttl
  records = var.record_type == "ALIAS" ? null : [var.record_value]

  dynamic "alias" {
    for_each = var.record_type == "ALIAS" ? [1] : []
    content {
      name                   = var.alias_dns_name
      zone_id                = var.alias_zone_id
      evaluate_target_health = false
    }
  }

  lifecycle {
    prevent_destroy = false

    precondition {
      condition = var.record_type == "ALIAS" ? (
        length(trimspace(var.alias_dns_name)) > 0 && length(trimspace(var.alias_zone_id)) > 0
      ) : length(trimspace(var.record_value)) > 0
      error_message = "ALIAS requires alias_dns_name and alias_zone_id; A/CNAME requires record_value."
    }

    precondition {
      condition     = var.record_type != "A" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.record_value))
      error_message = "For record_type A, record_value must have IPv4 address syntax."
    }
  }
}
