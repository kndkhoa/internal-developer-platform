variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "${{ values.awsRegion }}"
}

variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "${{ values.name }}"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "${{ values.environment }}"
}

variable "ecs_cluster_name" {
  description = "Name of the existing ECS cluster"
  type        = string
  default     = "${{ values.ecsClusterName }}"
}

variable "vpc_id" {
  description = "VPC ID for the service"
  type        = string
  default     = "${{ values.vpcId }}"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["${{ values.subnetIds | replace(",", "\", \"") }}"]
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = string
  default     = "${{ values.taskCpu }}"
}

variable "task_memory" {
  description = "Memory (MB) for the ECS task"
  type        = string
  default     = "${{ values.taskMemory }}"
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = ${{ values.desiredCount }}
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = ${{ values.containerPort }}
}

variable "enable_autoscaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = ${{ values.enableAutoScaling }}
}
