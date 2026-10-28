data "aws_vpc" "default" { default=true }
data "aws_subnets" "private" { filter { name="vpc-id" values=[data.aws_vpc.default.id] }; filter { name="tag:Name" values=["*private*"] } }
data "aws_subnets" "public" { filter { name="vpc-id" values=[data.aws_vpc.default.id] }; filter { name="tag:Name" values=["*public*"] } }
