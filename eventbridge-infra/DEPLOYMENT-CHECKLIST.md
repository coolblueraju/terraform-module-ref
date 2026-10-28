# EventBridge deployment checklist
- [ ] Confirm account number and AWS region.
- [ ] Configure exactly one of schedule_expression or event_pattern.
- [ ] Validate cron/rate syntax or event-pattern JSON/event shape.
- [ ] Confirm target_type is step_functions or lambda.
- [ ] Confirm the named state machine/Lambda already exists in the selected account/region.
- [ ] Review Step Functions StartExecution role or Lambda resource permission.
- [ ] Review standard/additional/apprepo tags.
- [ ] Run terraform fmt -recursive, terraform validate, and terraform plan.
- [ ] Apply and test the rule with a controlled event or schedule.
