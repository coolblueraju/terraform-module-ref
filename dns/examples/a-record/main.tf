provider "aws" { region = "us-east-2" }

module "dns" {
  source = "../../"

  environment  = "dev"
  app_name     = "myapp"
  record_type  = "A"
  record_value = "10.0.1.25"
  ttl          = 300
}
