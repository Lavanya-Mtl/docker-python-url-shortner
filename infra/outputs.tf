output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_name}"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}