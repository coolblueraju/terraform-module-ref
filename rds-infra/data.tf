data "aws_vpc" "default" { default=true }
data "aws_subnets" "private_pattern_one" {
  filter { name="vpc-id" values=[data.aws_vpc.default.id] }
  filter { name="tag:Name" values=["*privatesubnet-az1","*privatesubnet-az2"] }
}
data "aws_subnets" "private_pattern_two" {
  filter { name="vpc-id" values=[data.aws_vpc.default.id] }
  filter { name="tag:Name" values=["*private-subnet-${var.aws_region}a","*private-subnet-${var.aws_region}b"] }
}
data "aws_ssm_parameter" "master_username" { name=local.rds_user_parameter; with_decryption=true }
data "aws_ssm_parameter" "master_password" { name=local.rds_password_parameter; with_decryption=true }
