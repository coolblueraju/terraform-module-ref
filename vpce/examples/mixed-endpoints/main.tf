provider "aws" { region="us-east-2" }
module "vpce" {
  source="../../"; create_vpce_module=true
  vpc_endpoints={execute_api={service_name="com.amazonaws.us-east-2.execute-api",vpc_endpoint_type="Interface",private_dns_enabled=true},dynamodb_gateway={service_name="com.amazonaws.us-east-2.dynamodb",vpc_endpoint_type="Gateway"}}
  gateway_route_table_ids=["rtb-0123456789abcdef0","rtb-0fedcba9876543210"]
  primary_vpce_key="execute_api"; apigw_source_vpce_key="execute_api"
  aws_region="us-east-2"; aws_account_number="123456789012"; alb_short_name="integration"; env="test"
  application_owner_email="owner@umb.com"; project_ritm="RITM0000000"; git_repo_name="org/repo"; cmdb_id="CMDB-ID"
}
