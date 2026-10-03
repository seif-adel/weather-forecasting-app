# Weather Forecasting App (RapidAPI + FastAPI + AWS Terraform)

A complete full-stack weather app:
- Frontend: static web UI with weather icons and user-friendly cards.
- Backend: Python FastAPI service that calls RapidAPI Open Weather endpoint by city.
- Infra: Terraform for AWS networking/security/monitoring, S3 website, ECS Fargate backend, ALB, ECR.
- CI/CD: GitHub Actions pipeline for test + deploy.

RapidAPI docs used:
- https://rapidapi.com/worldapi/api/open-weather13/details
- https://rapidapi.com/worldapi/api/open-weather13/playground/V2%20-%20Current%20Weather%20by%20city%20name

## 1. Repository Structure

- `frontend/`: HTML/CSS/JS weather UI.
- `src/backend/`: FastAPI weather API, Dockerfile, tests.
- `infra/terraform/`: Terraform stack split by concern.
- `scripts/update-frontend-config.ps1`: Optional local config updater.
- `.github/workflows/ci-cd.yml`: CI/CD pipeline.

## 2. Backend API

### Endpoints
- `GET /health`
- `GET /api/weather?city=<CITY_NAME>`

Example:
```bash
curl "http://localhost:8000/api/weather?city=London"
```

Expected behavior:
- Valid city: returns weather JSON payload from provider.
- Invalid city: returns `404` with `{"detail":"City not found"}`.

## 3. Local Run

### Prerequisites
- Python 3.12+
- Docker + Docker Compose

### Option A: Python directly
```powershell
cd weather-forcasting-app
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r src/backend/requirements-dev.txt
$env:PYTHONPATH = "src/backend"
uvicorn app:app --app-dir src/backend --host 0.0.0.0 --port 8000
```

Set RapidAPI key in another terminal before calling weather endpoint:
```powershell
$env:RAPIDAPI_KEY = "your-rapidapi-key"
$env:RAPIDAPI_HOST = "open-weather13.p.rapidapi.com"
```

Open frontend:
- Open `frontend/index.html` in browser, or serve statically.

### Option B: Docker Compose
```powershell
cd weather-forcasting-app
$env:RAPIDAPI_KEY = "your-rapidapi-key"
docker compose up --build
```

URLs:
- Frontend: http://localhost:8080
- Backend: http://localhost:8000

## 4. Tests

Run tests:
```powershell
cd weather-forcasting-app
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r src/backend/requirements-dev.txt
$env:PYTHONPATH = "src/backend"
pytest src/backend/tests -q
```

Tests include:
- Health endpoint success.
- Weather success scenario.
- Wrong city scenario returning 404.

## 5. Terraform Deployment (AWS)

### Prerequisites
- AWS CLI configured
- Terraform >= 1.6
- Docker installed (for image build/push)

### Configure variables
```powershell
cd weather-forcasting-app
Copy-Item infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
```

Set secret variable in shell (recommended):
```powershell
$env:TF_VAR_rapidapi_key = "your-rapidapi-key"
```

Optional:
```powershell
$env:TF_VAR_alert_email = "you@example.com"
$env:TF_VAR_allow_public_frontend = "true"
```

### Apply
```powershell
terraform -chdir=infra/terraform init
terraform -chdir=infra/terraform validate
terraform -chdir=infra/terraform apply -auto-approve
```

Get outputs:
```powershell
terraform -chdir=infra/terraform output
```

## 6. CI/CD Pipeline (GitHub Actions)

Workflow file:
- `.github/workflows/ci-cd.yml`

Pipeline stages:
1. Install backend dependencies.
2. Run tests (including wrong-city behavior).
3. Configure AWS (OIDC).
4. Terraform init + validate.
5. Bootstrap ECR repo.
6. Build + push Docker image to ECR.
7. Terraform apply with image tag.

Required GitHub secrets:
- `AWS_REGION`
- `AWS_ROLE_TO_ASSUME`
- `RAPIDAPI_KEY`
- `ALERT_EMAIL` (optional)
- `TF_STATE_BUCKET`
- `TF_STATE_KEY`
- `TF_STATE_REGION`
- `TF_LOCK_TABLE`

## 7. Security and Monitoring Included

- Security groups isolate traffic path:
  - Internet -> ALB (80)
  - ALB -> ECS app port
- ECS logs to CloudWatch.
- CloudWatch alarm on ALB 5xx with SNS notifications.
- S3 and ECR encryption enabled.

## 8. Cleanup

```powershell
terraform -chdir=infra/terraform destroy -auto-approve
```
