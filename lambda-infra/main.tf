resource "aws_cloudwatch_log_group" "lambda" { name=local.log_group_name; retention_in_days=var.log_retention_days; tags=local.tags }
resource "aws_security_group" "lambda" { name="${var.lambda_name}-sg"; description="Security group for ${var.lambda_name}"; vpc_id=data.aws_vpc.default.id; egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }; tags=merge(local.tags,{Name="${var.lambda_name}-sg"}) }
resource "aws_security_group_rule" "additional" { for_each={for i,r in var.additional_security_group_rules:tostring(i)=>r}; type=each.value.type; from_port=each.value.from_port; to_port=each.value.to_port; protocol=each.value.protocol; cidr_blocks=length(each.value.cidr_blocks)>0?each.value.cidr_blocks:null; source_security_group_id=try(each.value.source_security_group_id,null); security_group_id=aws_security_group.lambda.id }
resource "aws_iam_role" "lambda" { name="${var.lambda_name}-role"; assume_role_policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Principal={Service="lambda.amazonaws.com"},Action="sts:AssumeRole"}]}); tags=local.tags }
resource "aws_iam_role_policy_attachment" "basic" { role=aws_iam_role.lambda.name; policy_arn="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" }
resource "aws_iam_role_policy_attachment" "vpc" { role=aws_iam_role.lambda.name; policy_arn="arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole" }
resource "aws_iam_role_policy_attachment" "s3" { role=aws_iam_role.lambda.name; policy_arn="arn:aws:iam::aws:policy/AmazonS3FullAccess" }
resource "aws_iam_role_policy_attachment" "ecs" { role=aws_iam_role.lambda.name; policy_arn="arn:aws:iam::aws:policy/AmazonECS_FullAccess" }
resource "aws_iam_role_policy_attachment" "ecr" { role=aws_iam_role.lambda.name; policy_arn="arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess" }
resource "aws_iam_role_policy_attachment" "cloudwatch" { role=aws_iam_role.lambda.name; policy_arn="arn:aws:iam::aws:policy/CloudWatchFullAccess" }
resource "aws_iam_role_policy" "dynamodb" {
  count=var.grant_dynamodb_access?1:0; name="${var.lambda_name}-dynamodb-access"; role=aws_iam_role.lambda.id
  policy=jsonencode({Version="2012-10-17",Statement=concat([{Effect="Allow",Action=local.effective_dynamodb_actions,Resource=[data.aws_dynamodb_table.target[0].arn,"${data.aws_dynamodb_table.target[0].arn}/index/*"]}],var.dynamodb_allow_stream_read?[{Effect="Allow",Action=["dynamodb:GetRecords","dynamodb:GetShardIterator","dynamodb:DescribeStream","dynamodb:ListStreams"],Resource=[data.aws_dynamodb_table.target[0].stream_arn]}]:[])})
  lifecycle { precondition { condition=!var.grant_dynamodb_access || (var.dynamodb_table_name!=null && length(trimspace(var.dynamodb_table_name))>0); error_message="dynamodb_table_name is required when grant_dynamodb_access=true." }; precondition { condition=!var.dynamodb_allow_stream_read || var.dynamodb_stream_enabled; error_message="dynamodb_allow_stream_read requires dynamodb_stream_enabled=true." } }
}
resource "aws_lambda_function" "this" {
  function_name=var.lambda_name; filename=var.lambda_zip_path; source_code_hash=filebase64sha256(var.lambda_zip_path); role=aws_iam_role.lambda.arn; handler=var.handler; runtime=var.runtime; timeout=var.timeout; memory_size=var.memory_size; publish=true
  vpc_config { subnet_ids=data.aws_subnets.private.ids; security_group_ids=[aws_security_group.lambda.id] }
  environment { variables=var.environment_variables }
  depends_on=[aws_cloudwatch_log_group.lambda,aws_iam_role_policy_attachment.basic,aws_iam_role_policy_attachment.vpc]
  lifecycle { precondition { condition=length(data.aws_subnets.private.ids)>0; error_message="No private subnets were found in the tagged default VPC." } }
  tags=local.tags
}
