data "aws_route53_zone" "private" {
  name         = local.zone_suffix
  private_zone = true
}
