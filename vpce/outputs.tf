output "vpc_endpoint_id" { description="Primary VPC endpoint ID."; value=local.effective_primary_key==null?null:aws_vpc_endpoint.this[local.effective_primary_key].id }
output "vpc_endpoint_arn" { description="Primary VPC endpoint ARN."; value=local.effective_primary_key==null?null:aws_vpc_endpoint.this[local.effective_primary_key].arn }
output "vpc_endpoint_dns_entries" { description="DNS entries for the primary endpoint."; value=local.effective_primary_key==null?[]:aws_vpc_endpoint.this[local.effective_primary_key].dns_entry }
output "vpc_endpoints" { description="All created endpoints keyed by endpoint key."; value={for k,e in aws_vpc_endpoint.this:k=>{id=e.id,arn=e.arn,type=e.vpc_endpoint_type,service_name=e.service_name,dns_entries=e.dns_entry}} }
output "vpce_eni_ips" { description="Private IPs of ENIs belonging to created Interface endpoints."; value=[for eni in data.aws_network_interface.endpoint:eni.private_ip] }
output "apigw_source_vpce_id" { description="Endpoint ID selected for API Gateway SourceVpce use."; value=local.effective_apigw_key==null?null:aws_vpc_endpoint.this[local.effective_apigw_key].id }
output "apigw_private_domain" { value=length(aws_api_gateway_domain_name.private)>0?aws_api_gateway_domain_name.private[0].domain_name:null }
output "apigw_private_domain_id" { value=length(aws_api_gateway_domain_name.private)>0?aws_api_gateway_domain_name.private[0].id:null }
output "apigw_public_domain" { value=length(aws_api_gateway_domain_name.public)>0?aws_api_gateway_domain_name.public[0].domain_name:null }
output "apigw_public_domain_id" { value=length(aws_api_gateway_domain_name.public)>0?aws_api_gateway_domain_name.public[0].id:null }
