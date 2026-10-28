# lambda-infra

Deployable Terraform module reconstructed from the supplied Lambda module specification. It creates one ZIP-based Lambda function in private subnets, a dedicated security group, execution IAM role, CloudWatch log group, broad S3/ECS/ECR/CloudWatch policies as documented, and optional DynamoDB access.

## Resource flow
`data.tf` locates the UMB-tagged VPC, private subnets, and optional DynamoDB table. `main.tf` creates the log group, SG, role/policy attachments, optional DynamoDB policy, and Lambda. The ZIP is hashed with `filebase64sha256`, so code changes produce Terraform updates. `publish=true` supplies version/qualified-ARN outputs.

## IAM
The role attaches AWSLambdaBasicExecutionRole, AWSLambdaVPCAccessExecutionRole, AmazonS3FullAccess, AmazonECS_FullAccess, AmazonEC2ContainerRegistryFullAccess, and CloudWatchFullAccess, matching the supplied broad-permission contract. These managed policies are operationally convenient but substantially broader than least privilege; a future major revision should scope S3/ECS/ECR/CloudWatch resources and actions.

## DynamoDB
When enabled, the target table is looked up and the inline policy scopes actions to the table and `/index/*`. An empty action list falls back to common read/write item operations. Optional stream access adds GetRecords, GetShardIterator, DescribeStream, and ListStreams; the caller must declare `dynamodb_stream_enabled=true`. This module grants IAM only; creating a Lambda event-source mapping is a separate resource/module responsibility.

## VPC
The module expects a VPC tagged `umbDefaultVPC=true` and `umbEnvironment=<mapped-env>`, plus private subnets whose Name contains `private`. `test` maps to `dev`; dev/qa/prod remain dev/qa/prod. Private Lambda functions need NAT or VPC endpoints for every required external/AWS service path.

## Local deployment package
Example PowerShell/Python workflow:
```powershell
New-Item -ItemType Directory -Force build
pip install -r requirements.txt -t build
Copy-Item app.py build\
Compress-Archive -Path build\* -DestinationPath function.zip -Force
```
Then reference `lambda_zip_path = "./function.zip"` from the Terraform root directory.

## Common_TF_Modules usage
Use the Git source as plain HCL, not rendered HTML:
```hcl
source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/lambda-infra/?ref=main"
```

## Deploy
```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Failure modes
- A missing ZIP fails before deployment because Terraform hashes the local file.
- No matching VPC/private subnets prevents VPC attachment.
- A VPC Lambda without NAT/endpoints can time out when reaching AWS APIs or the internet.
- DynamoDB stream IAM does not create a stream or event-source mapping.
- Secrets should not be put directly in `environment_variables`; prefer Secrets Manager/SSM references in a hardened revision.
