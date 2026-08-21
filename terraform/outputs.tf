output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.backstage.repository_url
}

output "alb_dns_name" {
  description = "ALB DNS name (access Backstage here)"
  value       = aws_lb.backstage.dns_name
}

output "backstage_url" {
  description = "Backstage URL"
  value       = "http://${aws_lb.backstage.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.backstage.endpoint
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.backstage.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group"
  value       = aws_cloudwatch_log_group.backstage.name
}
