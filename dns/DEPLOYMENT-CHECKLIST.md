# DNS deployment checklist

- [ ] Confirm the AWS account/provider is correct.
- [ ] Confirm the expected private hosted zone already exists.
- [ ] Confirm environment mapping: dev -> dev.aws.umb.com, qa -> qa.aws.umb.com, all other values -> aws.umb.com.
- [ ] Confirm `app_name` is the intended DNS label.
- [ ] For A/CNAME, verify `record_value` and TTL.
- [ ] For ALIAS, verify both target DNS name and canonical hosted-zone ID.
- [ ] Run `terraform fmt -recursive`.
- [ ] Run `terraform validate`.
- [ ] Review `terraform plan -out=tfplan`, especially FQDN and zone.
- [ ] Apply with `terraform apply tfplan`.
- [ ] Validate private DNS resolution from a VPC associated with the hosted zone.
