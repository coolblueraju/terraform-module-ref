data "aws_caller_identity" "current" {}
data "aws_ecr_repository" "service_repo" { name = local.ecr_name }
data "aws_ecr_image" "service_image" { repository_name = data.aws_ecr_repository.service_repo.name; most_recent = true }
data "aws_lb" "shared" { name = local.alb_name }
data "aws_lb_listener" "https" { load_balancer_arn = data.aws_lb.shared.arn; port = 443 }
data "aws_vpc" "default" { default = true }
data "aws_subnets" "private" { filter { name="vpc-id"; values=[data.aws_vpc.default.id] }; filter { name="tag:Name"; values=["*private*"] } }
