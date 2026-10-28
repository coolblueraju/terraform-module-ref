# Step Functions deployment checklist
- [ ] Workspace is test, qa, or prod.
- [ ] State-machine name is correct.
- [ ] STANDARD vs EXPRESS is selected deliberately.
- [ ] Placeholder definition has been replaced for production.
- [ ] Custom definition is valid JSON and valid Amazon States Language.
- [ ] Required Lambda/Batch/ECS/S3/DynamoDB task permissions are attached separately to the execution role.
- [ ] CloudWatch retention meets operational requirements.
- [ ] ERROR logging and disabled execution-data logging meet troubleshooting requirements.
- [ ] Run terraform fmt -recursive, terraform validate, and review terraform plan before apply.
