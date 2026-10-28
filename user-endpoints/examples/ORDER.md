# Suggested apply order
1. `alb/` with `alb_type = "internal"`
2. `nlb/`
3. `vpc-link/`
4. `vpce/` when private API endpoints/custom domains are needed
5. `alb/` public/private can consume `module.vpce.vpce_eni_ips`
6. `waf/`, followed by caller-owned `aws_wafv2_web_acl_association`
