# Arquitectura AWS con ECS Fargate y ALB - Proyecto bearozz
# Autor: Experto Terraform

locals {
  common_tags = {
    Project     = var.project_name
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
