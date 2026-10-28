# DynamoDB deployment checklist

- [ ] Confirm app/environment account and provider.
- [ ] Confirm table name or override.
- [ ] Confirm all table/GSI key attributes are declared.
- [ ] For PROVISIONED, confirm table and every GSI have positive RCU/WCU.
- [ ] If TTL is enabled, confirm the TTL attribute and application epoch-seconds behavior.
- [ ] If Streams are enabled, confirm stream view type and consumers.
- [ ] If KMS CMK is used, review key policy and IAM permissions.
- [ ] Review deletion protection before any destroy workflow.
- [ ] If IAM role creation is enabled, review trust principals and actions.
- [ ] Run terraform fmt -recursive, terraform validate, and terraform plan.
