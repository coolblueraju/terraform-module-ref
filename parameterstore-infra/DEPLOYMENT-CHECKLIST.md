# Parameter Store deployment checklist
- [ ] Confirm the full parameter path and environment segment.
- [ ] Select String, StringList, or SecureString deliberately.
- [ ] For StringList, confirm the value is a comma-separated list expected by consumers.
- [ ] For SecureString, confirm the default SSM encryption-key behavior meets the security requirement.
- [ ] Never commit secret parameter values to Git.
- [ ] Confirm Terraform remote state is encrypted and access-restricted.
- [ ] Confirm consuming IAM roles have only required `ssm:GetParameter*` and, where applicable, KMS permissions.
- [ ] Run `terraform fmt -recursive`, `terraform validate`, and review `terraform plan` before apply.
