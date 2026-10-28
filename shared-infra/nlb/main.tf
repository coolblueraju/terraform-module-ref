resource "aws_security_group" "nlb_sg" { name="${var.alb_short_name}-nlb-sg"; vpc_id=var.vpc_id; tags=local.tags }
resource "aws_security_group_rule" "ingress_nlb_https" { for_each=var.nlb_trusted_ip_ranges; type="ingress"; from_port=443; to_port=443; protocol="tcp"; cidr_blocks=[each.value.cidr]; description=each.value.description; security_group_id=aws_security_group.nlb_sg.id }
resource "aws_security_group_rule" "egress_nlb_traffic" { type="egress"; from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"]; security_group_id=aws_security_group.nlb_sg.id }
resource "aws_lb" "my_load_balancer" {
  name="${var.alb_short_name}-nlb"; internal=true; load_balancer_type="network"; security_groups=[aws_security_group.nlb_sg.id]; enable_deletion_protection=false
  subnet_mapping { subnet_id=var.private_subnets[0]; private_ipv4_address=var.nlb_staticips[0] }
  subnet_mapping { subnet_id=var.private_subnets[1]; private_ipv4_address=var.nlb_staticips[1] }
  subnet_mapping { subnet_id=var.private_subnets[2]; private_ipv4_address=var.nlb_staticips[2] }
  tags=local.tags; lifecycle { precondition { condition=local.compliant_env!=null; error_message="terraform.workspace must be test, qa, or prod." } }
}
resource "aws_lb_target_group" "my_target_group" { name="${var.alb_short_name}-alb-tg"; port=443; protocol="TCP"; target_type="alb"; vpc_id=var.vpc_id; health_check { enabled=true; protocol="HTTPS"; port="443"; path="/"; matcher="200,404" }; tags=local.tags }
resource "aws_lb_listener" "my_listener" { load_balancer_arn=aws_lb.my_load_balancer.arn; port=443; protocol="TCP"; default_action { type="forward"; target_group_arn=aws_lb_target_group.my_target_group.arn } }
resource "aws_lb_target_group_attachment" "tg_attachment" { target_group_arn=aws_lb_target_group.my_target_group.arn; target_id=var.alb_arn; port=443 }
