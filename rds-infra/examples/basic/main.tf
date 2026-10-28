provider "aws" { region="us-east-2" }
module "rds" {
  source="../../"
  rds_short_name="myapp"; env="qa"; instance_class="db.r6g.large"; engine_version="16.4"; dbparametergroupFamily="aurora-postgresql16"
  shared_buffers_by_size={large="2048",xlarge="4096"}; effective_cache_size_by_size={large="4096",xlarge="8192"}; work_mem_by_size={large="64",xlarge="128"}
  rdsinbound_ip_ranges={jumpbox={cidr="10.0.5.10/32",description="Jumpbox"}}
  application_owner_email="owner@umb.com"; project_ritm="RITM0012345"; git_repo_name="myapp-infra"; cmdb_id="APP-001234"
}
