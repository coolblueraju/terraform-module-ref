# vpce

Reusable VPC Endpoint module with simple service-driven defaults or an advanced multi-endpoint map.

## Modes
### Disabled
`create_vpce_module=false` creates no endpoints and primary outputs are null/empty.

### Simple/default
When `create_vpce_module=true` and `vpc_endpoints={}`, the module builds one endpoint from `vpce_service_type` or the full `vpce_service_name` override. `dynamodb` and `s3` default to `Gateway`; other service suffixes default to `Interface`.

### Advanced
`vpc_endpoints` can mix Interface and Gateway endpoints. Interface endpoints use auto-discovered private subnets plus a module SG that permits HTTPS from the VPC CIDR. Gateway endpoints use `gateway_route_table_ids` and fail early when the list is empty.

## Primary keys
`primary_vpce_key` controls legacy/single-endpoint outputs. `apigw_source_vpce_key` identifies the endpoint callers should use for API Gateway SourceVpce conditions. Both keys are validated against the configured endpoint map.

## Custom domains
When `create_apigw_custom_domains=true`, both certificate ARNs are required. This package creates the documented regional private/public domain names from the environment mapping. Because the exact original resource-policy/access-association schema was not fully supplied in the description, the generated module exposes `apigw_source_vpce_id` for the caller to use in the precise API Gateway domain policy/association required by its API type/provider version, rather than inventing unsupported arguments.

## Environment/domain mapping
`test` and `dev` map to `dev`; `qa` to `qa`; `prod` to `prod`. Default domains are `api-internal.services.<env>.aws.umb.com` and `api.<env>.umb.com`.

## Example commands
```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Important checks
1. Gateway endpoint route tables must correspond to the workloads that need S3/DynamoDB routes.
2. Interface endpoints incur hourly/ENI and data-processing charges and need DNS/security-group planning.
3. `private_dns_enabled` should be enabled deliberately because it changes service DNS resolution inside the VPC.
4. Feed `vpce_eni_ips` only into architectures explicitly designed to target endpoint ENIs.
5. API Gateway SourceVpce policies should use `apigw_source_vpce_id` and be tested from both allowed and disallowed networks.
