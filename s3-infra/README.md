# s3-infra

Reusable S3 module implementing encryption, versioning, public-access blocking, lifecycle policies, server access logging, bucket policy, Object Lock, Lambda notifications, and optional DynamoDB access for an existing dispatcher Lambda role.

## Line-by-line guide
- `aws_s3_bucket.this` creates the globally unique bucket, applies tags, force-destroy choice, and Object Lock creation flag.
- `aws_s3_bucket_versioning.this` enables or suspends versioning. Object Lock has a precondition requiring versioning.
- Encryption uses AES256 when no KMS key is supplied and `aws:kms` plus S3 Bucket Key when `kms_key_id` is supplied.
- The public-access block enables all four S3 public-access protections when `block_public_access=true`.
- Logging configuration requires an existing target bucket. The target logging bucket must itself be configured to accept S3 server access logs.
- Lifecycle rules dynamically add expiration, noncurrent-version expiration, and GLACIER transitions only when those values are supplied.
- Object Lock uses GOVERNANCE or COMPLIANCE default retention in days. Object Lock must be decided at bucket creation for this design.
- Lambda notifications create both the Lambda resource permission and S3 notification. One notification configuration is managed per module bucket.
- Optional DynamoDB access attaches an inline table/index policy to the existing `dispatcher_lambda_role_name`; it does not create that Lambda role.

## Security and operational cautions
The broad feature contract is preserved, but production callers should keep `block_public_access=true`, `force_destroy=false`, and prefer KMS where required by policy. COMPLIANCE Object Lock is intentionally difficult to bypass and should only be used after retention requirements are approved. A custom bucket policy can still cause outages or unexpected access if written incorrectly, so review it separately.

For Lambda notifications, S3 invokes the Lambda directly through a resource-based permission. If the Lambda is VPC-attached, that does not change the S3-to-Lambda invocation mechanism, but the function still needs network paths for whatever downstream services it calls.

## Deploy
```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Common_TF_Modules source
Use plain HCL, not rendered HTML:
```hcl
source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/s3-infra/?ref=vpce-dynamodb"
```
