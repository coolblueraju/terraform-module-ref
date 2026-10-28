resource "aws_db_subnet_group" "db_subnet_group" { name="${var.rds_short_name}-rds-subnet-group"; subnet_ids=local.selected_subnet_ids; tags=local.tags }
resource "aws_security_group" "rds_sg" { name="${var.rds_short_name}-rds-sg"; vpc_id=data.aws_vpc.default.id; tags=local.tags }
resource "aws_vpc_security_group_ingress_rule" "vpc" { security_group_id=aws_security_group.rds_sg.id; cidr_ipv4=data.aws_vpc.default.cidr_block; from_port=var.port; to_port=var.port; ip_protocol="tcp"; description="RDS access from VPC" }
resource "aws_vpc_security_group_ingress_rule" "additional" { for_each=var.rdsinbound_ip_ranges; security_group_id=aws_security_group.rds_sg.id; cidr_ipv4=each.value.cidr; from_port=var.port; to_port=var.port; ip_protocol="tcp"; description=each.value.description }
resource "aws_vpc_security_group_egress_rule" "all" { security_group_id=aws_security_group.rds_sg.id; cidr_ipv4="0.0.0.0/0"; ip_protocol="-1" }
resource "aws_rds_cluster_parameter_group" "rds_cluster_pg" {
  name="rds-${var.rds_short_name}-pg"; family=var.dbparametergroupFamily; description="Aurora PostgreSQL parameters for ${var.rds_short_name}"
  parameter { name="timezone"; value="UTC" }
  parameter { name="shared_buffers"; value=var.shared_buffers_by_size[local.instance_size] }
  parameter { name="work_mem"; value=var.work_mem_by_size[local.instance_size] }
  parameter { name="maintenance_work_mem"; value="65536" }
  parameter { name="effective_cache_size"; value=var.effective_cache_size_by_size[local.instance_size] }
  parameter { name="autovacuum"; value="1" }
  parameter { name="log_min_duration_statement"; value="1000" }
  parameter { name="max_parallel_maintenance_workers"; value="2" }
  parameter { name="rds.force_ssl"; value="1" }
  lifecycle {
    precondition { condition=contains(keys(var.shared_buffers_by_size),local.instance_size); error_message="shared_buffers_by_size is missing the derived instance size." }
    precondition { condition=contains(keys(var.effective_cache_size_by_size),local.instance_size); error_message="effective_cache_size_by_size is missing the derived instance size." }
    precondition { condition=contains(keys(var.work_mem_by_size),local.instance_size); error_message="work_mem_by_size is missing the derived instance size." }
  }
  tags=local.tags
}
resource "aws_rds_cluster" "rds" {
  cluster_identifier="${var.rds_short_name}-cluster"; engine="aurora-postgresql"; engine_version=var.engine_version; port=var.port
  master_username=data.aws_ssm_parameter.master_username.value; master_password=data.aws_ssm_parameter.master_password.value
  db_subnet_group_name=aws_db_subnet_group.db_subnet_group.name; vpc_security_group_ids=[aws_security_group.rds_sg.id]; db_cluster_parameter_group_name=aws_rds_cluster_parameter_group.rds_cluster_pg.name
  backup_retention_period=14; storage_encrypted=true; enabled_cloudwatch_logs_exports=["postgresql"]
  deletion_protection=false; skip_final_snapshot=true; final_snapshot_identifier="${var.rds_short_name}-final-snapshot"
  lifecycle {
    ignore_changes=[engine_version,allow_major_version_upgrade]
    precondition { condition=local.compliant_env!=null; error_message="terraform.workspace must be test, qa, or prod." }
    precondition { condition=length(local.selected_subnet_ids)==2; error_message="Exactly two matching private subnets are required for AZ1/AZ2." }
  }
  tags=local.tags
}
resource "aws_rds_cluster_instance" "rds_instance" {
  count=2; identifier="${var.rds_short_name}-${count.index}"; cluster_identifier=aws_rds_cluster.rds.id; instance_class=var.instance_class; engine=aws_rds_cluster.rds.engine; engine_version=aws_rds_cluster.rds.engine_version; db_subnet_group_name=aws_db_subnet_group.db_subnet_group.name; publicly_accessible=false; tags=local.tags
}
