variable "environment" {
  description = "Environment selector. dev maps to dev.aws.umb.com, qa to qa.aws.umb.com, and all other values to aws.umb.com."
  type        = string
  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment must not be empty."
  }
}

variable "app_name" {
  description = "DNS subdomain prefix."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$", var.app_name))
    error_message = "app_name must be a valid single DNS label containing letters, numbers, or hyphens."
  }
}

variable "record_type" {
  description = "DNS record type: A, CNAME, or ALIAS."
  type        = string
  validation {
    condition     = contains(["A", "CNAME", "ALIAS"], var.record_type)
    error_message = "record_type must be A, CNAME, or ALIAS."
  }
}

variable "record_value" {
  description = "IPv4 address for A records or target hostname for CNAME records. Not used for ALIAS."
  type        = string
  default     = ""
}

variable "alias_dns_name" {
  description = "ALB/NLB DNS name. Required for ALIAS records."
  type        = string
  default     = ""
}

variable "alias_zone_id" {
  description = "ALB/NLB canonical hosted zone ID. Required for ALIAS records."
  type        = string
  default     = ""
}

variable "ttl" {
  description = "TTL in seconds for A and CNAME records."
  type        = number
  default     = 300
  validation {
    condition     = var.ttl > 0
    error_message = "ttl must be greater than zero."
  }
}
