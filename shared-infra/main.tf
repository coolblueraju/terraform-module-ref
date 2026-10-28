module "alb" {
  source="./alb"
  alb_short_name=var.alb_short_name; env=var.env; cert_arn=var.cert_arn; vpc_id=data.aws_vpc.default.id; private_subnets=local.selected_private_subnets; alb_trusted_ip_ranges=var.alb_trusted_ip_ranges
  application_owner_email=var.application_owner_email; project_ritm=var.project_ritm; git_repo_name=var.git_repo_name; cmdb_id=var.cmdb_id; apprepo_tags=var.apprepo_tags
}
module "nlb" {
  count=var.create_nlb_module?1:0; source="./nlb"
  alb_short_name=var.alb_short_name; env=var.env; vpc_id=data.aws_vpc.default.id; private_subnets=local.selected_private_subnets; nlb_staticips=var.nlb_staticips; nlb_trusted_ip_ranges=var.nlb_trusted_ip_ranges; alb_arn=module.alb.alb_arn
  application_owner_email=var.application_owner_email; project_ritm=var.project_ritm; git_repo_name=var.git_repo_name; cmdb_id=var.cmdb_id; apprepo_tags=var.apprepo_tags
  depends_on=[module.alb]
}
resource "aws_security_group_rule" "ingress_alb_https_from_nlb" {
  count=var.create_nlb_module?1:0; type="ingress"; from_port=443; to_port=443; protocol="tcp"; source_security_group_id=module.nlb[0].nlb_sg_id; security_group_id=module.alb.alb_sg_id; description="Allow NLB to ALB HTTPS"
}
resource "terraform_data" "validation" {
  lifecycle {
    precondition { condition=length(local.selected_private_subnets)==3; error_message="Exactly three matching private subnets are required." }
    precondition { condition=!var.create_nlb_module || length(var.nlb_staticips)==3; error_message="NLB mode requires exactly three static private IPs." }
  }
}
