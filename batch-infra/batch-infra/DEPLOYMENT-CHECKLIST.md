# Deployment checklist

- [ ] Replace the module source with the Common_TF_Modules Git URL and a fixed release tag.
- [ ] Confirm AWS credentials with `aws sts get-caller-identity`.
- [ ] Confirm `aws_account_number` and `aws_region` match the active provider.
- [ ] Verify the default VPC exists, or adapt the module to accept a VPC ID.
- [ ] Supply `subnet_ids` if subnet Name tags do not match the documented patterns.
- [ ] Confirm private subnets have NAT or the required VPC endpoints.
- [ ] Review default outbound security-group access.
- [ ] Review Secrets Manager, SSM, S3, RDS, and CloudWatch IAM permissions.
- [ ] Confirm the selected Fargate vCPU/memory combination is supported.
- [ ] Run `terraform fmt -recursive`, `terraform validate`, and `terraform plan`.
- [ ] Apply Terraform before attempting to push to the new ECR repository.
- [ ] Build and push the image using the same value as `batch_image_tag`.
- [ ] Submit a test job and inspect `/aws/batch/<job_definition_name>`.
