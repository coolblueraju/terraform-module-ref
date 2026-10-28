provider "aws" { region = "us-east-2" }

module "dns" {
  source = "../../"

  environment  = "qa"
  app_name     = "myapp"
  record_type  = "CNAME"
  record_value = "target.example.com"
  ttl          = 300
}
