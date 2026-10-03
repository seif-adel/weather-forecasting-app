output "api_base_url" {
  description = "Backend API base URL"
  value       = "http://${aws_lb.app.dns_name}"
}

output "frontend_url" {
  description = "Frontend website URL"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "ecr_repository_url" {
  description = "ECR repository for backend image"
  value       = aws_ecr_repository.backend.repository_url
}
