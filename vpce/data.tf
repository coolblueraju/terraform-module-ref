data "aws_vpc" "default" { default=true }
data "aws_subnets" "private" {
  filter { name="vpc-id" values=[data.aws_vpc.default.id] }
  filter { name="tag:Name" values=["*private*"] }
}
data "aws_network_interface" "endpoint" {
  for_each = toset(flatten([for e in aws_vpc_endpoint.this : e.network_interface_ids]))
  id       = each.value
}
