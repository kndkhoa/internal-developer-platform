locals {
  common_tags = {
    Service     = var.service_name
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedBy   = "backstage-scaffolder"
  }
}
