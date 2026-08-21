---
inclusion: auto
---

# AWS Credit — Danh sách services được tài trợ miễn phí

⚠️ **QUY TẮC QUAN TRỌNG**: Khi tạo bất kỳ AWS service/resource nào, PHẢI kiểm tra xem nó có nằm trong danh sách dưới đây không. Nếu KHÔNG có trong list → KHÔNG được tạo, phải tìm giải pháp thay thế nằm trong list.

## Danh sách services nằm trong credit (Account 787309525126)

1. Amazon Simple Storage Service (S3)
2. AWS Lambda
3. AWS Data Transfer
4. Elastic Load Balancing (ALB/NLB)
5. Amazon Relational Database Service (RDS)
6. Amazon Machine Learning
7. Amazon CloudSearch
8. Amazon Bedrock
9. Amazon Elastic Container Service (ECS)
10. Amazon Elastic Compute Cloud (EC2)
11. Amazon DynamoDB
12. Amazon API Gateway
13. Amazon Route 53
14. Amazon Elastic Container Service for Kubernetes (EKS)
15. Amazon Bedrock AgentCore
16. Amazon Elastic Container Registry Public (ECR)
17. Amazon Elastic File System (EFS)
18. Amazon CloudWatch
19. AWS WAF
20. Amazon OpenSearch Service
21. Amazon ElastiCache
22. Amazon CloudFront
23. Amazon Virtual Private Cloud (VPC)

## Services KHÔNG nằm trong credit (TRÁNH dùng)

- ❌ NAT Gateway (~$32/tháng)
- ❌ Elastic IP (khi không gắn resource)
- ❌ AWS Secrets Manager (dùng SSM Parameter Store free tier thay thế)
- ❌ AWS Transfer Family
- ❌ Amazon Redshift

## Nguyên tắc thay thế

| Cần | Thay bằng (trong credit) |
|---|---|
| NAT Gateway | ECS public subnet + public IP |
| Secrets storage | SSM Parameter Store (free) hoặc env vars trong Task Definition |
| File storage | S3 |
| Full-text search | OpenSearch hoặc PostgreSQL full-text |
