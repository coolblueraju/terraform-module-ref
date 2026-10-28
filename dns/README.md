# dns

Reusable Terraform module for creating one A, CNAME, or ALIAS record in an environment-specific private Route 53 hosted zone.

## Structure

- `versions.tf`: Terraform/AWS provider requirements.
- `locals.tf`: environment-to-zone mapping, FQDN, and ALIAS-to-A translation.
- `data.tf`: private hosted-zone lookup.
- `variables.tf`: inputs and validations.
- `main.tf`: Route 53 record and conditional alias block.
- `outputs.tf`: FQDN, hosted-zone ID, and actual Route 53 type.
- `examples/`: ALIAS, CNAME, and A examples.

## Line-by-line usage guide

### `locals.tf`

`zone_suffix` maps `dev` to `dev.aws.umb.com`, `qa` to `qa.aws.umb.com`, and every other non-empty environment to `aws.umb.com`, preserving the supplied module behavior. `fqdn` joins `app_name` and that suffix. `aws_record_type` converts the consumer-friendly `ALIAS` value to the Route 53 `A` type required by the module design.

### `data.tf`

`aws_route53_zone.private` searches for the selected hosted-zone name with `private_zone = true`. The module therefore does not create a hosted zone and does not target a public zone. The caller must run against an AWS account/provider context where the expected private zone is visible.

### `variables.tf`

`environment` cannot be blank. Note that values other than `dev` and `qa` intentionally map to the production-style `aws.umb.com` zone, matching the supplied contract.

`app_name` must be one DNS label using letters, numbers, and hyphens.

`record_type` is restricted to `A`, `CNAME`, or `ALIAS`.

`record_value` is used only by A/CNAME. `alias_dns_name` and `alias_zone_id` are used only by ALIAS. `ttl` defaults to 300 seconds and applies only to non-alias records.

### `main.tf`

`zone_id` comes from the private-zone data lookup. `name` is the calculated FQDN. `type` is A for ALIAS and otherwise the requested type.

`ttl` and `records` become `null` for ALIAS because Route 53 aliases use the nested `alias` block instead. The dynamic alias block appears only when `record_type == "ALIAS"` and supplies the load-balancer DNS name, canonical hosted-zone ID, and `evaluate_target_health = false`.

The lifecycle block preserves `prevent_destroy = false`. Preconditions reject missing alias fields or a missing A/CNAME value. A records also receive a basic IPv4-shape validation. This validation catches obvious malformed input, but it is not an octet-range validator.

### `outputs.tf`

`fqdn` returns the created record name. `zone_id` helps confirm which private hosted zone was selected. `record_type` returns the actual Route 53 type, so an input of ALIAS reports A.

## Common_TF_Modules usage

Use a plain Git source string, not HTML copied from a rendered link:

```hcl
module "dns" {
  source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/dns/?ref=v4.0.0"

  environment    = var.env
  app_name       = "myapp"
  record_type    = "ALIAS"
  alias_dns_name = module.shared_infra.alb_dns_name
  alias_zone_id  = module.shared_infra.alb_zone_id
}
```

## A record

```hcl
module "dns" {
  source       = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/dns/?ref=v4.0.0"
  environment  = "dev"
  app_name     = "myapp"
  record_type  = "A"
  record_value = "10.0.1.25"
  ttl          = 300
}
```

Result: `myapp.dev.aws.umb.com` pointing to `10.0.1.25`.

## CNAME

```hcl
module "dns" {
  source       = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/dns/?ref=v4.0.0"
  environment  = "qa"
  app_name     = "myapp"
  record_type  = "CNAME"
  record_value = "target.example.com"
  ttl          = 300
}
```

Result: `myapp.qa.aws.umb.com` pointing to `target.example.com`.

## Deploy from PowerShell

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Important failure modes

1. `environment = "prod"` and any value other than `dev`/`qa` intentionally select `aws.umb.com`. A typo such as `environment = "qaa"` therefore also selects `aws.umb.com`; review plans carefully.
2. The private hosted zone must already exist. This module creates only the record.
3. ALIAS requires both the target DNS name and its canonical hosted-zone ID. For ALB/NLB usage, consume both from the relevant load-balancer resource/module output rather than hardcoding them.
4. Route 53 private-zone resolution also depends on the VPC associations and DNS settings of the existing hosted zone/VPC. Record creation alone does not make an unrelated VPC able to resolve the name.
5. `prevent_destroy = false` means removing the resource from configuration can delete the DNS record.
