provider "aws" { region = "us-east-2" }

module "dns" {
  source = "../../"

  environment    = "qa"
  app_name       = "myapp"
  record_type    = "ALIAS"
  alias_dns_name = "internal-myapp-123456.us-east-2.elb.amazonaws.com"
  alias_zone_id  = "Z3AADJGX6KTTL2"
}
