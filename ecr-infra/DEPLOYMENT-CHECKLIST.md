# ECR deployment checklist

- [ ] Confirm the AWS account and provider region.
- [ ] Confirm `app_short_name` produces the expected `<app>-ecr` name.
- [ ] Confirm Terraform workspace is exactly `test`, `qa`, or `prod`.
- [ ] Confirm mapped environment tag: test -> dev, qa -> qa, prod -> prod.
- [ ] Review `apprepo_tags` overrides.
- [ ] Confirm AES256 is acceptable; KMS is not exposed at the wrapper level.
- [ ] Confirm retaining only two images is acceptable for rollback requirements.
- [ ] Run `terraform fmt -recursive` and `terraform validate`.
- [ ] Review `terraform plan -out=tfplan`.
- [ ] Apply and verify `terraform output -raw ecr_repo_url`.
- [ ] Push a test image and verify scan results and lifecycle behavior.
