variable "project_name" {
  description = "Project short name"
  type        = string
  default     = "weather"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Two public subnet CIDRs"
  type        = list(string)
  default     = ["10.50.1.0/24", "10.50.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Two private subnet CIDRs"
  type        = list(string)
  default     = ["10.50.11.0/24", "10.50.12.0/24"]
}

variable "container_port" {
  description = "Backend container port"
  type        = number
  default     = 8000
}

variable "image_tag" {
  description = "Docker image tag deployed to ECS"
  type        = string
  default     = "latest"
}

variable "rapidapi_key" {
  description = "RapidAPI key used by backend container"
  type        = string
  sensitive   = true
}

variable "rapidapi_host" {
  description = "RapidAPI host header"
  type        = string
  default     = "open-weather13.p.rapidapi.com"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "alert_email" {
  description = "Email for CloudWatch alarm subscription"
  type        = string
  default     = ""
}

variable "allow_public_frontend" {
  description = "Whether to attach a public-read S3 bucket policy for the frontend website"
  type        = bool
  default     = false
}
