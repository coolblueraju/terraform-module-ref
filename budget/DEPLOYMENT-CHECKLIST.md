# Deployment checklist

- Confirm `umbAppName` is available as a billing/cost-allocation tag.
- Confirm every intended application resource receives the matching `umbAppName` value.
- Confirm `application_support_group` is the correct distribution email.
- Confirm `monthly_budget` is in USD and is greater than zero.
- Run `terraform fmt -recursive`.
- Run `terraform validate`.
- Run `terraform plan -out=tfplan` and review the budget name, filter, tags, amount, and notification.
- Apply using `terraform apply tfplan`.
- Verify the budget in AWS Billing and Cost Management.
