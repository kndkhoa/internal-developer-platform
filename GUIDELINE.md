# Backstage Project - Guideline

## Tổng quan

Project Backstage developer portal, dùng để quản lý tập trung tất cả services, APIs, và tài nguyên của tổ chức.

---

## Cách chạy Local

### Yêu cầu
- Node.js phiên bản 22 hoặc 24
- Yarn 4.4.1 (đã có sẵn trong `.yarn/releases/`)

### Cài dependencies
```bash
yarn install
```

### Chạy frontend (port 3001)
```bash
yarn workspace app start --config ../../app-config.yaml
```
Frontend: http://localhost:3001

### Chạy backend (port 7007)
```bash
yarn workspace backend start --config ../../app-config.yaml
```
Backend: http://localhost:7007

### Chạy cả 2 cùng lúc
```bash
yarn start
```

### Lưu ý
- Nếu gặp lỗi `EADDRINUSE` (port đang bị chiếm):
```bash
kill -9 $(lsof -ti tcp:3001)   # kill process trên port 3001
kill -9 $(lsof -ti tcp:7007)   # kill process trên port 7007
```
- Frontend cần backend chạy để load được (gọi API tới port 7007)

---

## Cấu hình đã thực hiện

### 1. GitHub Integration

**File:** `app-config.yaml`

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

**Token** được lưu trong file `.env` ở root project:
```
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx
```

> `.env` đã nằm trong `.gitignore`, không bị commit lên repo.

### 2. GitHub Auto-Discovery (Catalog tự quét repo)

**Plugin đã cài:**
```bash
yarn workspace backend add @backstage/plugin-catalog-backend-module-github
```

**Đăng ký trong backend** (`packages/backend/src/index.ts`):
```typescript
backend.add(import('@backstage/plugin-catalog-backend-module-github'));
```

**Cấu hình trong** `app-config.yaml`:
```yaml
catalog:
  providers:
    github:
      kndkhoa:
        organization: 'kndkhoa'
        catalogPath: '/catalog-info.yaml'
        filters:
          branch: 'main'
          repository: '.*'
        schedule:
          frequency: { minutes: 5 }
          timeout: { minutes: 3 }
```

**Cách hoạt động:**
- Backstage tự quét tất cả repo trong account `kndkhoa` mỗi 5 phút
- Repo nào có file `catalog-info.yaml` ở branch `main` sẽ tự động được import vào Catalog
- Không cần vào config thêm mỗi khi có repo mới

---

## Catalog - Hướng dẫn sử dụng

### File mẫu: `catalog-info.yaml`

Đặt file này ở root của mỗi repo trên GitHub:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  description: "Mô tả ngắn về service"
  annotations:
    github.com/project-slug: kndkhoa/my-service
  tags:
    - java
spec:
  type: service          # service | website | library
  lifecycle: production  # experimental | development | production | deprecated
  owner: team-backend
```

File mẫu đầy đủ có tại: `examples/catalog-info-sample.yaml`

### Các loại entity

| Kind | Mô tả |
|------|--------|
| Component | Service, website, library |
| API | Interface expose ra (REST, gRPC, GraphQL) |
| System | Nhóm các component liên quan |
| Resource | Database, S3, queue, redis... |
| Group/User | Team và người dùng |
| Template | Template tạo project mới |

---

## Cấu trúc Project

```
backstage/
├── app-config.yaml          # Config chính (ports, integrations, catalog...)
├── app-config.production.yaml
├── .env                     # Secrets (GITHUB_TOKEN)
├── packages/
│   ├── app/                 # Frontend (React)
│   └── backend/             # Backend (Node.js)
│       └── src/index.ts     # Đăng ký plugins
├── plugins/                 # Custom plugins
└── examples/
    ├── entities.yaml              # Entity mẫu
    ├── catalog-info-sample.yaml   # File mẫu catalog-info.yaml
    ├── template/                  # Template Node.js mẫu
    └── springboot-template/       # Template Spring Boot + AWS ECS
        ├── template.yaml
        └── content/               # Skeleton: code + CI/CD + Terraform
```

---

## Tính năng cần làm thêm (TODO)

- [ ] Cấu hình GitLab integration
- [ ] Thêm GitHub Auth provider (login bằng GitHub)
- [x] Cấu hình TechDocs (tự generate docs từ repo)
- [x] Thêm Scaffolder templates (tạo project mới từ template)
- [ ] Cấu hình Kubernetes plugin
- [ ] Deploy lên production
- [ ] Thêm custom theme/branding

---

## TechDocs - Cấu hình

### Yêu cầu trên máy local
```bash
pip3 install mkdocs-techdocs-core
```

### Config (`app-config.yaml`)
```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'local'    # cần mkdocs cài trên máy
  publisher:
    type: 'local'
```

### Cấu trúc docs trong repo
```
repo/
├── mkdocs.yml           # Bắt buộc
├── docs/
│   └── index.md         # Bắt buộc
└── catalog-info.yaml    # annotation: backstage.io/techdocs-ref: dir:.
```

Nếu docs nằm trong subfolder (ví dụ `implementation/`):
```yaml
backstage.io/techdocs-ref: url:https://github.com/kndkhoa/talentradar/tree/main/implementation
```

### Lưu ý khi start backend
Cần thêm PATH để tìm được `mkdocs`:
```bash
export PATH="/Users/khoaknd/Library/Python/3.13/bin:$PATH"
```

---

## Scaffolder Templates

### Spring Boot + AWS ECS Fargate Template

Đã tạo template tại `examples/springboot-template/`

**Cấu trúc:**
```
examples/springboot-template/
├── template.yaml                          # Form + steps
└── content/                               # Code skeleton
    ├── pom.xml                            # Spring Boot 3.3, Java 21, Prometheus metrics
    ├── Dockerfile                         # Multi-stage, non-root user, healthcheck
    ├── .gitignore
    ├── catalog-info.yaml                  # Auto-register + AWS annotations
    ├── README.md
    ├── .github/
    │   └── workflows/
    │       └── build-deploy.yml           # CI/CD: build → ECR → ECS deploy
    ├── terraform/
    │   ├── main.tf                        # ECR, ECS Task/Service, ALB, IAM, SG
    │   ├── variables.tf                   # Params từ template form
    │   ├── outputs.tf                     # ECR URL, ALB DNS, service name
    │   └── locals.tf                      # Common tags
    └── src/
        ├── main/java/{package}/
        │   ├── Application.java
        │   └── controller/HealthController.java
        ├── main/resources/application.yml  # Multi-profile (dev/staging/prod)
        └── test/java/{package}/ApplicationTest.java
```

**Form parameters trên UI:**

| Step | Field | Mô tả |
|------|-------|--------|
| Service Info | name | Tên service (lowercase, dashes) |
| | description | Mô tả |
| | groupId | Maven Group ID |
| | artifactId | Maven Artifact ID |
| | javaPackage | Java package |
| | owner | Team sở hữu |
| AWS Config | awsAccountId | AWS Account ID (12 digits) |
| | ecsClusterName | Tên ECS cluster đã có |
| | vpcId | VPC ID |
| | subnetIds | Subnet IDs (comma-separated) |
| | environment | dev / staging / production |
| | taskCpu | 0.25 - 2 vCPU |
| | taskMemory | 512 MB - 4 GB |
| | desiredCount | Số task ban đầu |
| | enableAutoScaling | Bật auto scaling |
| | containerPort | Port (mặc định 8080) |
| Repo | repoUrl | github.com/kndkhoa/ten-service |

**Cách sử dụng:**
1. Vào **Create** → chọn **"Spring Boot Service (AWS ECS Fargate)"**
2. Điền thông tin service + AWS config
3. Chọn repo location
4. Click **Create**

**Backstage sẽ tự động:**
1. Tạo repo **private** trên GitHub với code đầy đủ
2. Repo có sẵn GitHub Actions → push to `main` sẽ:
   - Build Maven + run tests
   - Build Docker image → push lên ECR
   - Update ECS task definition → deploy ECS service
3. Đăng ký vào Catalog

**Sau khi tạo xong, cần chạy Terraform 1 lần để provision infra:**
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform sẽ tạo:
- ECR repository (scan on push, keep 10 images)
- CloudWatch Log Group (/ecs/service-name)
- IAM Roles (task execution + task)
- Security Groups (ALB + ECS tasks)
- Application Load Balancer + Target Group
- ECS Task Definition (Fargate)
- ECS Service
- Auto Scaling (nếu enabled)

**Flow khi developer push code:**
```
git push → GitHub Actions → Maven build → Docker build → Push ECR → Deploy ECS → Rolling update
```

**Repo mới sẽ nằm trên GitHub** tại URL bạn chọn (ví dụ `github.com/kndkhoa/payment-service`)

### Lưu ý quan trọng

1. **AWS Secrets**: Sau khi tạo repo, vào GitHub repo → Settings → Secrets → thêm `AWS_ACCESS_KEY_ID` và `AWS_SECRET_ACCESS_KEY` thật
2. **Terraform state**: Config backend S3 bucket `terraform-state-{accountId}` — cần tạo bucket này trước
3. **ECS Cluster**: Phải có sẵn cluster trên AWS (template không tạo cluster mới)

---

## Lệnh start đầy đủ (cần nhớ)

```bash
# Backend (cần cả GITHUB_TOKEN và PATH cho mkdocs)
export PATH="/Users/khoaknd/Library/Python/3.13/bin:$PATH" && export $(cat .env | xargs) && yarn workspace backend start --config ../../app-config.yaml

# Frontend
yarn workspace app start --config ../../app-config.yaml
```

---

## Changelog

| Ngày | Nội dung |
|------|----------|
| 2024-08-19 | Setup ban đầu: chạy local, GitHub integration, auto-discovery catalog |
| 2024-08-19 | TechDocs: cài mkdocs, config runIn local, fix techdocs-ref annotation |
| 2024-08-19 | Scaffolder: tạo Spring Boot template với Java 21, Maven, Docker |
| 2024-08-19 | Nâng cấp template: thêm GitHub Actions CI/CD, ECR push, ECS Fargate deploy, Terraform |
| 2024-08-19 | Tạo GUIDELINE.md + hook PostTaskExec để tự nhắc update |
