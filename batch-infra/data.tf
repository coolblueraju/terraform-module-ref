data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private_pattern_one" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*privatesubnet-az1", "*privatesubnet-az2", "*privatesubnet-az3"]
  }
}

data "aws_subnets" "private_pattern_two" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "tag:Name"
    values = [
      "*private-subnet-${var.aws_region}a",
      "*private-subnet-${var.aws_region}b",
      "*private-subnet-${var.aws_region}c"
    ]
  }
}
