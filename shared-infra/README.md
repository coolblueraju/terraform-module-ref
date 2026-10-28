# shared-infra

Reusable internal ALB module with an optional static-private-IP NLB in front. The top-level wrapper composes `alb/` and `nlb/`.

## Flow
ALB-only: trusted CIDRs -> ALB SG -> internal ALB -> HTTPS:443 listener -> fixed 404. Application modules add listener rules/target groups later.

ALB+NLB: partner CIDRs -> NLB SG -> internal NLB static IPs -> TCP:443 target group (`target_type=alb`) -> ALB:443. A top-level SG rule permits NLB SG -> ALB SG on 443.

## Line-by-line guide
`data.tf` finds the default VPC and private subnets by either documented naming pattern. Three unique subnet IDs are selected and validated.

`module.alb` always runs. It creates `<name>-alb-sg`, CIDR ingress rules, all-egress, `<name>-alb`, and an HTTPS 443 listener using the ACM certificate. ALB deletion protection is always enabled. The listener deliberately returns 404 by default so application services own routing rules.

`module.nlb` uses `count` and runs only when `create_nlb_module=true`. It requires three static IPs and three private subnets. It creates `<name>-nlb-sg`, the internal network load balancer, `<name>-alb-tg`, TCP 443 listener, and ALB target attachment. NLB deletion protection is false.

Both nested modules require Terraform workspace `test`, `qa`, or `prod`, tagged as `dev`, `qa`, or `prod` respectively.

## ALB-only deployment
```powershell
terraform init
terraform workspace select qa
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Use top-level outputs `alb_dns_name` and `zone_id` with the DNS module's ALIAS inputs.

## NLB deployment
Set `create_nlb_module=true` and provide exactly three private IPv4 addresses corresponding to the three private subnets. Confirm those addresses are unused and valid inside each subnet CIDR before apply.

## Important cautions
1. ALB deletion protection must be disabled in code before Terraform can destroy the ALB.
2. No forwarding listener rule is provided by shared-infra. ECS/service modules are expected to create path/host rules.
3. NLB static IP/subnet order matters. Wildcard subnet discovery can return an order that is not equivalent to AZ1/AZ2/AZ3 naming. For strict production static-IP mapping, a future revision should resolve each AZ subnet independently rather than slice a combined set.
4. Top-level outputs deliberately expose only ALB details, preserving the stated contract.
5. The user-provided specification says `alb_trusted_ip_ranges` has enterprise office/VPN defaults, but those actual CIDRs were not provided. This generated package therefore uses `{}` safely rather than inventing internal network ranges. Populate the approved CIDRs in the caller or restore the sanctioned defaults from the source repository.
