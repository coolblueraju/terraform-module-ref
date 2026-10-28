# Secrets Manager deployment checklist
- [ ] Confirm the exact secret name/path.
- [ ] Confirm whether the value is plain text or JSON expected by consumers.
- [ ] Keep secret values out of Git and unencrypted `.tfvars` files.
- [ ] Verify Terraform remote state encryption and access restrictions.
- [ ] Review recovery window: 30 is the default; 0 permits immediate deletion.
- [ ] Confirm AWS-managed Secrets Manager encryption meets requirements; no CMK input exists in this module.
- [ ] Confirm Terraform, not an external rotation process, is intended to own the value.
- [ ] Run terraform fmt, validate, and plan before apply.
