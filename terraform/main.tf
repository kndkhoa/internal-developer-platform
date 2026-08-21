terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────
# ECR Repository
# ─────────────────────────────────────────────
resource "aws_ecr_repository" "backstage" {
  name                 = var.service_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "backstage" {
  repository = aws_ecr_repository.backstage.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ─────────────────────────────────────────────
# CloudWatch Log Group
# ─────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "backstage" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 14

  tags = local.common_tags
}

# ─────────────────────────────────────────────
# IAM Roles
# ─────────────────────────────────────────────
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.service_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow pulling secrets from SSM/Secrets Manager
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name = "${var.service_name}-secrets-policy"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.service_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# ─────────────────────────────────────────────
# Security Groups
# ─────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.service_name}-alb-sg"
  description = "Security group for Backstage ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "ecs" {
  name        = "${var.service_name}-ecs-sg"
  description = "Security group for Backstage ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 7007
    to_port         = 7007
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "rds" {
  name        = "${var.service_name}-rds-sg"
  description = "Security group for Backstage RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# ─────────────────────────────────────────────
# RDS PostgreSQL
# ─────────────────────────────────────────────
resource "aws_db_subnet_group" "backstage" {
  name       = "${var.service_name}-db-subnet"
  subnet_ids = var.private_subnet_ids

  tags = local.common_tags
}

resource "aws_db_instance" "backstage" {
  identifier     = "${var.service_name}-db"
  engine         = "postgres"
  engine_version = "15"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"

  db_name  = "backstage"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.backstage.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false
  publicly_accessible     = false

  tags = local.common_tags
}

# ─────────────────────────────────────────────
# ALB (Application Load Balancer)
# ─────────────────────────────────────────────
resource "aws_lb" "backstage" {
  name               = "${var.service_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = local.common_tags
}

resource "aws_lb_target_group" "backstage" {
  name        = "${var.service_name}-tg"
  port        = 7007
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/api/health"
    matcher             = "200"
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backstage.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backstage.arn
  }
}

# ─────────────────────────────────────────────
# ECS Task Definition
# ─────────────────────────────────────────────
resource "aws_ecs_task_definition" "backstage" {
  family                   = "${var.service_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${aws_ecr_repository.backstage.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 7007
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "APP_BASE_URL", value = "http://${aws_lb.backstage.dns_name}" },
        { name = "BACKEND_BASE_URL", value = "http://${aws_lb.backstage.dns_name}" },
        { name = "POSTGRES_HOST", value = aws_db_instance.backstage.address },
        { name = "POSTGRES_PORT", value = "5432" },
        { name = "POSTGRES_USER", value = var.db_username },
        { name = "POSTGRES_PASSWORD", value = var.db_password },
        { name = "GITHUB_TOKEN", value = var.github_token },
        { name = "PGSSLMODE", value = "require" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backstage.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = local.common_tags
}

# ─────────────────────────────────────────────
# ECS Service
# ─────────────────────────────────────────────
resource "aws_ecs_service" "backstage" {
  name            = "${var.service_name}-service"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.backstage.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backstage.arn
    container_name   = var.service_name
    container_port   = 7007
  }

  depends_on = [aws_lb_listener.http]

  tags = local.common_tags
}
