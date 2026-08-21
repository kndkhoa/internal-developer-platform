# ${{ values.name }}

${{ values.description }}

## Tech Stack

- Java 21
- Spring Boot 3.3
- PostgreSQL
- Maven
- Docker
- AWS ECS Fargate
- Terraform

## Local Development

```bash
# Run locally
mvn spring-boot:run

# Run with specific profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

App runs at: http://localhost:${{ values.containerPort }}

## Docker

```bash
docker build -t ${{ values.name }} .
docker run -p ${{ values.containerPort }}:${{ values.containerPort }} ${{ values.name }}
```

## Infrastructure (Terraform)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This provisions:
- ECR repository
- ECS Task Definition + Service (Fargate)
- Application Load Balancer
- Security Groups
- CloudWatch Log Group
- Auto Scaling (if enabled)

## CI/CD

Push to `main` triggers GitHub Actions:
1. Build Java (Maven)
2. Run tests
3. Build Docker image
4. Push to ECR
5. Deploy to ECS (rolling update)

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Service info |
| GET | `/actuator/health` | Health check |
| GET | `/actuator/info` | App info |
| GET | `/actuator/metrics` | Metrics |

## AWS Resources

| Resource | Value |
|----------|-------|
| Region | ${{ values.awsRegion }} |
| ECS Cluster | ${{ values.ecsClusterName }} |
| ECR Repository | ${{ values.awsAccountId }}.dkr.ecr.${{ values.awsRegion }}.amazonaws.com/${{ values.name }} |
| Log Group | /ecs/${{ values.name }} |
