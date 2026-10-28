resource "aws_s3_bucket" "this" {
  bucket=var.bucket_name; force_destroy=var.force_destroy; object_lock_enabled=var.enable_object_lock; tags=local.tags
  lifecycle {
    precondition { condition=!var.enable_object_lock || var.versioning_enabled; error_message="Object Lock requires versioning_enabled=true." }
    precondition { condition=!var.enable_logging || (var.logging_target_bucket!=null && length(trimspace(var.logging_target_bucket))>0); error_message="logging_target_bucket is required when enable_logging=true." }
    precondition { condition=!var.enable_event_notification || (var.lambda_function_arn!=null && length(trimspace(var.lambda_function_arn))>0); error_message="lambda_function_arn is required when event notification is enabled." }
  }
}
resource "aws_s3_bucket_versioning" "this" { bucket=aws_s3_bucket.this.id; versioning_configuration { status=var.versioning_enabled?"Enabled":"Suspended" } }
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count=var.enable_encryption?1:0; bucket=aws_s3_bucket.this.id
  rule { apply_server_side_encryption_by_default { sse_algorithm=var.kms_key_id!=null?"aws:kms":"AES256"; kms_master_key_id=var.kms_key_id } bucket_key_enabled=var.kms_key_id!=null }
}
resource "aws_s3_bucket_public_access_block" "this" { count=var.block_public_access?1:0; bucket=aws_s3_bucket.this.id; block_public_acls=true; ignore_public_acls=true; block_public_policy=true; restrict_public_buckets=true }
resource "aws_s3_bucket_logging" "this" { count=var.enable_logging?1:0; bucket=aws_s3_bucket.this.id; target_bucket=var.logging_target_bucket; target_prefix=var.logging_target_prefix }
resource "aws_s3_bucket_policy" "this" { count=var.bucket_policy!=null?1:0; bucket=aws_s3_bucket.this.id; policy=var.bucket_policy }
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count=length(var.lifecycle_rules)>0?1:0; bucket=aws_s3_bucket.this.id
  dynamic "rule" { for_each=var.lifecycle_rules; content {
    id=rule.value.id; status=rule.value.enabled?"Enabled":"Disabled"
    filter { prefix=rule.value.prefix }
    dynamic "expiration" { for_each=rule.value.expiration_days!=null?[1]:[]; content { days=rule.value.expiration_days } }
    dynamic "noncurrent_version_expiration" { for_each=rule.value.noncurrent_version_expiration!=null?[1]:[]; content { noncurrent_days=rule.value.noncurrent_version_expiration } }
    dynamic "transition" { for_each=rule.value.transition_glacier_days!=null?[1]:[]; content { days=rule.value.transition_glacier_days; storage_class="GLACIER" } }
  } }
  depends_on=[aws_s3_bucket_versioning.this]
}
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count=var.enable_object_lock?1:0; bucket=aws_s3_bucket.this.id
  rule { default_retention { mode=var.object_lock_mode; days=var.object_lock_days } }
  depends_on=[aws_s3_bucket_versioning.this]
}
resource "aws_lambda_permission" "s3" {
  count=var.enable_event_notification?1:0; statement_id="AllowS3Invoke-${substr(md5(var.bucket_name),0,8)}"; action="lambda:InvokeFunction"; function_name=var.lambda_function_arn; principal="s3.amazonaws.com"; source_arn=aws_s3_bucket.this.arn
}
resource "aws_s3_bucket_notification" "lambda" {
  count=var.enable_event_notification?1:0; bucket=aws_s3_bucket.this.id
  lambda_function { lambda_function_arn=var.lambda_function_arn; events=var.event_types; filter_prefix=var.event_notification_filter_prefix; filter_suffix=var.event_notification_filter_suffix }
  depends_on=[aws_lambda_permission.s3]
}
resource "aws_iam_role_policy" "dispatcher_dynamodb" {
  count=var.grant_dynamodb_access?1:0; name="${var.app_short_name}-s3-dispatcher-dynamodb"; role=var.dispatcher_lambda_role_name
  policy=jsonencode({Version="2012-10-17",Statement=[{Effect="Allow",Action=local.effective_dynamodb_actions,Resource=[data.aws_dynamodb_table.dispatcher[0].arn,"${data.aws_dynamodb_table.dispatcher[0].arn}/index/*"]}]})
  lifecycle { precondition { condition=!var.grant_dynamodb_access || (var.dynamodb_table_name!=null && var.dispatcher_lambda_role_name!=null && length(trimspace(var.dispatcher_lambda_role_name))>0); error_message="DynamoDB access requires dynamodb_table_name and dispatcher_lambda_role_name." } }
}
