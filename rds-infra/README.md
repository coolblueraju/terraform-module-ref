# rds-infra

Reusable Terraform module for a two-instance Aurora PostgreSQL cluster. Credentials are read from existing SSM Parameter Store entries rather than generated.

## Files
- `versions.tf`: Terraform/AWS provider requirements.
- `data.tf`: default VPC, private subnet, and SSM credential lookups.
- `locals.tf`: workspace mapping, naming, instance-size derivation, subnet selection, tags.
- `main.tf`: subnet group, SG, parameter group, Aurora cluster, and two instances.
- `output.tf`: writer and reader endpoints.
- `examples/basic`: complete example.

## Line-by-line guide
### Prerequisites
`<rds_short_name>-rds-user` and `<rds_short_name>-rds-password` must exist in SSM before planning. Terraform reads them with decryption. Because these values enter Terraform evaluation/state, secure the Terraform backend and restrict state access.

### Network discovery
The module uses the default VPC and searches two documented Name-tag styles for AZ1/AZ2 private subnets. It de-duplicates matches and selects two. A precondition requires exactly two selected subnet IDs. Review plan output if your account has multiple subnet names matching the wildcards.

### Parameter tuning
The last segment of `instance_class` is the tuning key. `db.r6g.large` becomes `large`. The three caller maps must therefore contain `large`. Preconditions produce explicit failures when keys are missing. The parameter group also sets UTC timezone, maintenance work memory, autovacuum, slow-query threshold, parallel maintenance workers, and forced SSL.

### Security group
The cluster port defaults to 8432. The SG permits that port from the complete VPC CIDR and from each `rdsinbound_ip_ranges` CIDR. It permits all outbound traffic. This matches the supplied contract, but VPC-wide inbound DB access is broader than application-SG-to-RDS-SG rules; consider tightening in a future major version.

### Cluster
The resource uses Aurora PostgreSQL, 14-day backup retention, encryption at rest, PostgreSQL CloudWatch log export and the custom cluster parameter group. `deletion_protection=false` and `skip_final_snapshot=true` are preserved. Although `final_snapshot_identifier` is populated, `skip_final_snapshot=true` means the destroy path does not rely on a final snapshot. `engine_version` and `allow_major_version_upgrade` are ignored for drift per the supplied design.

### Instances
Exactly two cluster instances are created as `<rds_short_name>-0` and `-1`. They use the same instance class and subnet group and are not publicly accessible.

### Workspace mapping
`test -> dev`, `qa -> qa`, `prod -> prod`. Other Terraform workspaces fail with a clear validation precondition.

## Usage
Use a plain Terraform source string:
```hcl
source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/rds-infra/?ref=v4.0.0"
```

For QA:
```powershell
terraform init
terraform workspace select qa
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Important operational cautions
1. `skip_final_snapshot=true` means no final snapshot is taken during Terraform destroy despite the identifier field.
2. `deletion_protection=false` allows Terraform to delete the cluster.
3. SSM credentials can flow into state. Encrypt and tightly control the backend.
4. The subnet discovery convention must match your account.
5. Verify engine version compatibility with the parameter-group family before apply.
6. Tuning values should be validated against the chosen Aurora instance class and workload rather than copied blindly between applications.
