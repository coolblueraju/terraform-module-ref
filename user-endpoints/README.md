# user-endpoints

Collection of independent Terraform submodules. There is intentionally no root `main.tf`. Consumers call `alb/`, `nlb/`, `vpc-link/`, `vpce/`, and `waf/` separately.

## Deployment order
For API Gateway to an internal ALB through VPC Link: internal ALB -> NLB -> VPC Link. `vpce` and `waf` can be deployed when required. WAF association remains caller-managed.

## Workspace requirement
Every submodule maps Terraform workspace `test -> dev`, `qa -> qa`, `prod -> prod`. Other workspaces fail explicitly.

## ALB
Creates public/private/internal ALBs with HTTPS 443, deletion protection, optional mTLS trust store from S3, optional VPCE-IP forwarding for public/private types, and internal path-pass-through target groups.

## NLB
Looks up `<alb_short_name>-internal-alb`, creates `<alb_short_name>-vpclink-nlb` with exactly three static private IPs, TCP 443, `target_type = "alb"`, and attaches the ALB. Per the supplied contract, NLB SG inbound is `0.0.0.0/0:443`.

## VPC Link
Looks up `<alb_short_name>-vpclink-nlb` and creates an API Gateway VPC Link.

## VPCE
Creates execute-api and API Gateway management interface endpoints, VPCE SG, returns endpoint ENI IPs, and can create private/public API Gateway custom domains. The management endpoint service intentionally preserves the supplied hardcoded `us-east-2` behavior.

## WAF
Creates `<alb_short_name>-waf`, configurable allow/block default, and optional AWSManagedRulesCommonRuleSet. Association is deliberately not automatic.

## Production review items
1. Replace empty trusted-CIDR defaults with approved corporate ranges. No internal CIDRs were invented.
2. Review the NLB `0.0.0.0/0:443` SG rule even if access is intended through API Gateway VPC Link.
3. VPCE endpoint policy is intentionally broad per the supplied design; API/custom-domain policies should provide the actual restriction.
4. Static NLB IPs must belong to their corresponding three VPC Link subnets and be unused.
5. mTLS verify mode requires a valid CA bundle in S3 and a trust store.
6. WAF must be associated separately with the intended ALB/API Gateway resource.
