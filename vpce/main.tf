resource "aws_security_group" "vpce" {
  count=var.create_vpce_module && length(local.interface_keys)>0?1:0
  name="${var.alb_short_name}-vpce-sg"; vpc_id=data.aws_vpc.default.id
  ingress { from_port=443; to_port=443; protocol="tcp"; cidr_blocks=[data.aws_vpc.default.cidr_block] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
  tags=local.tags
}
resource "aws_vpc_endpoint" "this" {
  for_each=local.effective_endpoints
  vpc_id=data.aws_vpc.default.id
  service_name=each.value.service_name
  vpc_endpoint_type=each.value.vpc_endpoint_type
  private_dns_enabled=each.value.vpc_endpoint_type=="Interface"?each.value.private_dns_enabled:null
  subnet_ids=each.value.vpc_endpoint_type=="Interface"?data.aws_subnets.private.ids:null
  security_group_ids=each.value.vpc_endpoint_type=="Interface"?[aws_security_group.vpce[0].id]:null
  route_table_ids=each.value.vpc_endpoint_type=="Gateway"?var.gateway_route_table_ids:null
  tags=merge(local.tags,{Name="pe-${replace(lower(var.vpce_service_type),"_","-")}-vpce",EndpointKey=each.key})
  lifecycle {
    precondition { condition=each.value.vpc_endpoint_type!="Gateway" || length(var.gateway_route_table_ids)>0; error_message="Gateway endpoints require gateway_route_table_ids." }
    precondition { condition=each.value.vpc_endpoint_type!="Interface" || length(data.aws_subnets.private.ids)>0; error_message="Interface endpoints require discoverable private subnets." }
  }
}
resource "terraform_data" "key_validation" {
  lifecycle {
    precondition { condition=local.effective_primary_key==null || contains(local.endpoint_keys,local.effective_primary_key); error_message="primary_vpce_key must reference a configured endpoint key." }
    precondition { condition=!var.create_apigw_custom_domains || (local.effective_apigw_key!=null && contains(local.endpoint_keys,local.effective_apigw_key)); error_message="apigw_source_vpce_key must reference a configured endpoint when custom domains are enabled." }
    precondition { condition=!var.create_apigw_custom_domains || (var.private_cert_arn!=null && var.public_cert_arn!=null); error_message="private_cert_arn and public_cert_arn are required for custom domains." }
  }
}
resource "aws_api_gateway_domain_name" "private" {
  count=var.create_apigw_custom_domains?1:0
  domain_name=local.private_domain; regional_certificate_arn=var.private_cert_arn; security_policy="TLS_1_2"
  endpoint_configuration { types=["REGIONAL"] }
  tags=local.tags
  depends_on=[terraform_data.key_validation]
}
resource "aws_api_gateway_domain_name" "public" {
  count=var.create_apigw_custom_domains?1:0
  domain_name=local.public_domain; regional_certificate_arn=var.public_cert_arn; security_policy="TLS_1_2"
  endpoint_configuration { types=["REGIONAL"] }
  tags=local.tags
  depends_on=[terraform_data.key_validation]
}
