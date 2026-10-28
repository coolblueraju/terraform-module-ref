# dynamodb-infra

Reusable Terraform module for one DynamoDB table with optional TTL, PITR, Streams, GSIs, KMS encryption, deletion protection, and a least-privilege IAM access role.

## Files

- `versions.tf`: Terraform/AWS provider requirements.
- `locals.tf`: effective table name, default IAM actions, tag merging, and key validation sets.
- `variables.tf`: inputs and validations.
- `main.tf`: DynamoDB table plus optional IAM role/policy.
- `outputs.tf`: table and optional role outputs.
- `examples/`: deployable usage patterns.

## Line-by-line guide

### Naming
`local.table_name` uses `table_name_override` when supplied; otherwise it builds `<app_short_name>-<table_suffix>`. The defaults therefore turn `myapp` into `myapp-table`. Environment is not added to names because the supplied design uses separate AWS accounts per environment.

### Attributes and keys
`hash_key` is always required. `range_key` becomes `null` when empty. The `attribute` dynamic block creates definitions only from `attributes`. DynamoDB attribute definitions should represent key-schema/index attributes, not every application JSON property. A lifecycle precondition verifies table and GSI key names are present in `attributes`.

### Billing
`PAY_PER_REQUEST` is the default. Table capacity values are `null` in on-demand mode. `PROVISIONED` requires positive table RCU/WCU values and positive RCU/WCU values on every GSI.

### TTL
When `ttl_enabled = true`, the dynamic TTL block configures `ttl_attribute`. A precondition prevents TTL being enabled with a blank attribute name. DynamoDB TTL values written by your application must be Unix epoch time in seconds.

### PITR and deletion protection
`point_in_time_recovery` controls PITR. `deletion_protection_enabled` defaults to true, so disable it deliberately before attempting table deletion through Terraform.

### Streams
`stream_enabled` enables a DynamoDB Stream and `stream_view_type` selects KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES. `allow_stream_read` adds GetRecords, GetShardIterator, DescribeStream, and ListStreams to the optional role and is rejected unless streams are enabled.

### Encryption
Server-side encryption is enabled. A blank `kms_key_arn` leaves the provider/AWS default DynamoDB encryption behavior in place; a supplied ARN selects a customer-managed KMS key. Callers and DynamoDB must also satisfy the KMS key policy/permissions.

### GSIs
Each GSI supplies name, hash key, optional range key, projection type, and optional non-key attributes. In PAY_PER_REQUEST mode capacity fields are ignored. In PROVISIONED mode each GSI must specify positive capacities.

### IAM role
`create_access_role = true` creates `pe-<app_short_name>-dynamodb-access-role` and its inline `pe-<app_short_name>-dynamodb-access-policy`. Trust can contain a service principal, caller role ARNs, or both. At least one trusted principal is required.

The default table policy grants GetItem, PutItem, UpdateItem, DeleteItem, Query, Scan, BatchGetItem, BatchWriteItem, and ConditionCheckItem against the table and its indexes. It does not grant table administration. Set `access_actions` to a smaller list for read-only or other constrained use.

## Common_TF_Modules example

Use the Git source as plain HCL, without HTML markup:

```hcl
module "dynamodb" {
  source = "git::https://github.com/UMBFC/Common_TF_Modules.git//modules/dynamodb-infra/?ref=v4.0.0"

  app_short_name = "myapp"
  env            = "qa"
  hash_key       = "pk"
  range_key      = "sk"
  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" }
  ]

  application_owner_email = var.application_owner_email
  project_ritm            = var.project_ritm
  git_repo_name           = var.git_repo_name
  cmdb_id                 = var.cmdb_id
}
```

## PowerShell deployment

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Production checks

- Deletion protection defaults to true.
- Avoid storing secrets in tags or table configuration.
- For Lambda Streams, creating this role does not itself create an event-source mapping; the Lambda module/resource still needs `aws_lambda_event_source_mapping`.
- For a customer KMS key, review its key policy and consumer permissions.
- For high-throughput predictable workloads, model PROVISIONED RCU/WCU and GSI capacity deliberately. For variable workloads, PAY_PER_REQUEST avoids manual capacity settings.
