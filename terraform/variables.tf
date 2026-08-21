variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "service_name" {
  description = "Service name"
  type        = string
  default     = "backstage-idp"
}

variable "ecs_cluster_name" {
  description = "Existing ECS cluster name"
  type        = string
  default     = "talentradar"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0cd7876498471bd2d"
}

variable "public_subnet_ids" {
  description = "Public subnet IDs (for ALB + ECS)"
  type        = list(string)
  default     = ["subnet-02854133786503b81", "subnet-00489741e1099fb56"]
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (for RDS)"
  type        = list(string)
  default     = ["subnet-069de1eba9b989478", "subnet-0ffb897f3e66cc6eb"]
}

variable "task_cpu" {
  description = "ECS task CPU units"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "ECS task memory (MB)"
  type        = string
  default     = "1024"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "backstage"
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub token for Backstage integrations"
  type        = string
  sensitive   = true
}
