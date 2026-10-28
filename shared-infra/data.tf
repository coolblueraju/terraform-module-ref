data "aws_vpc" "default" { default=true }
data "aws_subnets" "private_pattern_one" {
  filter { name="vpc-id" values=[data.aws_vpc.default.id] }
  filter { name="tag:Name" values=["*privatesubnet-az1","*privatesubnet-az2","*privatesubnet-az3"] }
}
data "aws_subnets" "private_pattern_two" {
  filter { name="vpc-id" values=[data.aws_vpc.default.id] }
  filter { name="tag:Name" values=["*private-subnet-*a","*private-subnet-*b","*private-subnet-*c"] }
}
