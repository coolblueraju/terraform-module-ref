provider "aws" { region="us-east-2" }
module "vpce" {
  source="../../"
  create_vpce_module=true
  vpce_service_type="dynamodb"
  gateway_route_table_ids=["rtb-0123456789abcdef0","rtb-0fedcba9876543210"]
  aws_region="us-east-2"; aws_account_number="123456789012"; alb_short_name="fdic"; env="qa"
  application_owner_email="owner@umb.com"; project_ritm="RITM0000000"; git_repo_name="org/repo"; cmdb_id="CMDB-ID"
}
