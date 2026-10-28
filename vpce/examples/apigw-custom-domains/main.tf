provider "aws" { region="us-east-2" }
module "vpce" {
  source="../../"; create_vpce_module=true
  vpc_endpoints={execute_api={service_name="com.amazonaws.us-east-2.execute-api",vpc_endpoint_type="Interface",private_dns_enabled=true}}
  primary_vpce_key="execute_api"; apigw_source_vpce_key="execute_api"; create_apigw_custom_domains=true
  private_cert_arn="arn:aws:acm:us-east-2:123456789012:certificate/private-cert-id"; public_cert_arn="arn:aws:acm:us-east-2:123456789012:certificate/public-cert-id"
  aws_region="us-east-2"; aws_account_number="123456789012"; alb_short_name="experience"; env="qa"
  application_owner_email="owner@umb.com"; project_ritm="RITM0000000"; git_repo_name="org/repo"; cmdb_id="CMDB-ID"
}
