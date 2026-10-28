output "fqdn" {
  description = "Fully qualified domain name created by the module."
  value       = aws_route53_record.dns_record.fqdn
}

output "zone_id" {
  description = "Private Route 53 hosted zone ID containing the record."
  value       = data.aws_route53_zone.private.zone_id
}

output "record_type" {
  description = "AWS Route 53 record type actually created. ALIAS is represented as A."
  value       = aws_route53_record.dns_record.type
}
