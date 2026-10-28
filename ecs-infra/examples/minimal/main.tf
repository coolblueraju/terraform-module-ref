provider "aws" { region = "us-east-2" }
module "ecs_infra" {
  source="../../"
  app_short_name="myapp"; env="qa"; alb_short_name="shared"
  cpu="512"; memory="1024"; port=8080; health_check_path="/health"; lister_rule_uri_pattern="/myapp/*"
  min_capacity=2; max_capacity=6; ALBAvgCPUPerTarget=60; env_vars={STAGE="qa"}
  application_owner_email="owner@umb.com"; project_ritm="RITM0012345"; git_repo_name="myapp-infra"; cmdb_id="APP-001234"
}
