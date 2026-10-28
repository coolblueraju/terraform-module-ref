locals {
  private_subnets = distinct(concat(data.aws_subnets.private_pattern_one.ids,data.aws_subnets.private_pattern_two.ids))
  selected_private_subnets = slice(local.private_subnets,0,min(3,length(local.private_subnets)))
}
