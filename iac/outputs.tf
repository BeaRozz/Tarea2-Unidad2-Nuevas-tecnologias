# Outputs bearozz
output "alb_dns_name" {
  description = "DNS del Load Balancer para probar la app"
  value       = aws_lb.alb_bearozz.dns_name
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = aws_ecr_repository.ecr_bearozz.repository_url
}
