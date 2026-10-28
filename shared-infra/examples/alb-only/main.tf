provider "aws" { region="us-east-2" }
module "shared_infra" { source="../../"; alb_short_name="myapp"; env="qa"; cert_arn="arn:aws:acm:us-east-2:123456789012:certificate/abc"; nlb_staticips=[]; nlb_trusted_ip_ranges={}; application_owner_email="owner@umb.com"; project_ritm="RITM0012345"; git_repo_name="myapp-infra"; cmdb_id="APP-001234" }
