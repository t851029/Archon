# Cloud Run Deployment Guide 2025

## Container Optimization

### Multi-Stage Docker Build

```dockerfile
# Build stage - compile and build
FROM node:20-alpine AS builder
WORKDIR /app

# Copy dependency files first (cache optimization)
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .
RUN npm run build

# Remove dev dependencies
RUN npm prune --production

# Runtime stage - minimal image
FROM gcr.io/distroless/nodejs20-debian11
WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./

# Set non-root user
USER nonroot

# Start application
CMD ["dist/index.js"]
```

### Python FastAPI Optimization

```dockerfile
# Build stage
FROM python:3.11-slim AS builder
WORKDIR /app

# Install Poetry
RUN pip install poetry==1.7.1

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Install dependencies
RUN poetry config virtualenvs.create false && \
    poetry install --only=main --no-root

# Runtime stage
FROM python:3.11-slim
WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code
COPY . .

# Run as non-root
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Start FastAPI
CMD ["uvicorn", "api.index:app", "--host", "0.0.0.0", "--port", "8080"]
```

## Health Checks Configuration

### Comprehensive Health Checks

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: backend-service
  annotations:
    run.googleapis.com/launch-stage: GA
spec:
  template:
    metadata:
      annotations:
        run.googleapis.com/execution-environment: gen2
        run.googleapis.com/startup-cpu-boost: "true"
    spec:
      containers:
        - image: gcr.io/project/backend:latest
          ports:
            - containerPort: 8080
          startupProbe:
            httpGet:
              path: /health/startup
              port: 8080
            initialDelaySeconds: 0
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 5
          livenessProbe:
            httpGet:
              path: /health/live
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 30
            timeoutSeconds: 10
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
```

### Health Endpoint Implementation

```python
from fastapi import FastAPI, Response
from datetime import datetime
import asyncio

app = FastAPI()

startup_time = None
is_ready = False

@app.on_event("startup")
async def startup_event():
    global startup_time, is_ready
    startup_time = datetime.now()
    # Perform initialization
    await initialize_services()
    is_ready = True

@app.get("/health/startup")
async def health_startup(response: Response):
    """Called during container startup"""
    if startup_time:
        return {"status": "ok", "started_at": startup_time.isoformat()}
    response.status_code = 503
    return {"status": "starting"}

@app.get("/health/live")
async def health_live():
    """Called to check if container should be restarted"""
    # Check critical dependencies
    try:
        await check_database_connection()
        return {"status": "healthy"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}, 503

@app.get("/health/ready")
async def health_ready(response: Response):
    """Called to check if container can receive traffic"""
    if is_ready and await check_all_services():
        return {"status": "ready"}
    response.status_code = 503
    return {"status": "not_ready"}
```

## Secret Management

### Environment Variables vs Volume Mounts

```yaml
# Environment variables - good for static secrets
env:
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        key: staging-api-key
        name: staging-api-key

# Volume mounts - good for dynamic secrets
volumes:
  - name: config
    secret:
      secretName: app-config
containers:
  - volumeMounts:
      - name: config
        mountPath: /secrets
        readOnly: true
```

### Secret Rotation Without Downtime

```python
import os
import json
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class SecretReloader(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path == "/secrets/config.json":
            self.reload_secrets()

    def reload_secrets(self):
        with open("/secrets/config.json") as f:
            new_config = json.load(f)
            # Update application configuration
            app.config.update(new_config)
            logger.info("Secrets reloaded successfully")

# Watch for secret changes
observer = Observer()
observer.schedule(SecretReloader(), "/secrets", recursive=False)
observer.start()
```

## Traffic Management

### Blue-Green Deployment

```bash
# Deploy new version without traffic
gcloud run deploy backend \
  --image gcr.io/project/backend:v2 \
  --no-traffic \
  --tag blue

# Test the new version
curl https://blue---backend-abc123-uc.a.run.app/health

# Gradually shift traffic
gcloud run services update-traffic backend \
  --to-tags blue=10

# Monitor metrics
sleep 300  # Wait 5 minutes

# Continue rollout or rollback
gcloud run services update-traffic backend \
  --to-tags blue=50

# Complete rollout
gcloud run services update-traffic backend \
  --to-latest
```

### Canary Deployment with Monitoring

```python
# deployment_monitor.py
import time
from google.cloud import monitoring_v3

def monitor_canary_deployment(project_id, service_name, canary_percentage):
    client = monitoring_v3.MetricServiceClient()
    project_name = f"projects/{project_id}"

    # Define metrics to monitor
    metrics = [
        "run.googleapis.com/request_latencies",
        "run.googleapis.com/request_count",
        "run.googleapis.com/response_count"
    ]

    # Set thresholds
    error_rate_threshold = 0.05  # 5%
    latency_threshold = 1000  # 1 second

    # Monitor for 10 minutes
    start_time = time.time()
    while time.time() - start_time < 600:
        # Check metrics
        error_rate = get_error_rate(client, project_name, service_name)
        avg_latency = get_average_latency(client, project_name, service_name)

        if error_rate > error_rate_threshold or avg_latency > latency_threshold:
            print(f"⚠️ Canary deployment failed: error_rate={error_rate}, latency={avg_latency}")
            rollback_deployment(service_name)
            return False

        time.sleep(30)

    print("✅ Canary deployment successful")
    return True
```

## Autoscaling Configuration

### Optimal Scaling Settings

```yaml
metadata:
  annotations:
    # Minimum instances (prevent cold starts)
    run.googleapis.com/minScale: "1"

    # Maximum instances (cost control)
    run.googleapis.com/maxScale: "100"

    # CPU allocation
    run.googleapis.com/cpu-throttling: "false"

    # Startup boost for faster cold starts
    run.googleapis.com/startup-cpu-boost: "true"

spec:
  # Concurrent requests per instance
  containerConcurrency: 80

  # Request timeout
  timeoutSeconds: 300

  # Service account
  serviceAccountName: backend-sa
```

### Custom Autoscaling Metrics

```python
# Export custom metrics for autoscaling
from google.cloud import monitoring_v3
import time

class MetricsExporter:
    def __init__(self, project_id):
        self.client = monitoring_v3.MetricServiceClient()
        self.project_name = f"projects/{project_id}"

    def export_queue_depth(self, queue_size):
        """Export queue depth for autoscaling"""
        series = monitoring_v3.TimeSeries()
        series.metric.type = "custom.googleapis.com/queue/depth"
        series.resource.type = "global"

        point = monitoring_v3.Point()
        point.value.int64_value = queue_size
        point.interval.end_time.seconds = int(time.time())

        series.points = [point]

        self.client.create_time_series(
            name=self.project_name,
            time_series=[series]
        )
```

## Monitoring and Observability

### Structured Logging

```python
import json
import logging
from pythonjsonlogger import jsonlogger

# Configure JSON logging
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger = logging.getLogger()
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

# Log with trace context
def log_request(request_id, user_id, action, duration_ms):
    logger.info(
        "request_processed",
        extra={
            "request_id": request_id,
            "user_id": user_id,
            "action": action,
            "duration_ms": duration_ms,
            "severity": "INFO",
            "trace": f"projects/{PROJECT_ID}/traces/{request_id}"
        }
    )
```

### Distributed Tracing

```python
from opentelemetry import trace
from opentelemetry.exporter.cloud_trace import CloudTraceSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Setup tracing
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

cloud_trace_exporter = CloudTraceSpanExporter()
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(cloud_trace_exporter)
)

# Use in application
@app.get("/api/users/{user_id}")
async def get_user(user_id: str):
    with tracer.start_as_current_span("get_user") as span:
        span.set_attribute("user.id", user_id)

        # Database operation
        with tracer.start_as_current_span("db_query"):
            user = await fetch_user_from_db(user_id)

        # Cache operation
        with tracer.start_as_current_span("cache_set"):
            await set_user_in_cache(user_id, user)

        return user
```

## Cost Optimization

### Request Coalescing

```python
from asyncio import Queue, create_task, gather
import time

class RequestCoalescer:
    def __init__(self, batch_size=10, max_wait_ms=50):
        self.batch_size = batch_size
        self.max_wait_ms = max_wait_ms
        self.queue = Queue()
        self.processing = False

    async def add_request(self, request):
        await self.queue.put(request)
        if not self.processing:
            create_task(self._process_batch())

    async def _process_batch(self):
        self.processing = True
        batch = []
        start_time = time.time()

        while len(batch) < self.batch_size:
            try:
                # Wait for request or timeout
                timeout = (self.max_wait_ms / 1000) - (time.time() - start_time)
                if timeout <= 0:
                    break

                request = await asyncio.wait_for(
                    self.queue.get(),
                    timeout=timeout
                )
                batch.append(request)
            except asyncio.TimeoutError:
                break

        if batch:
            # Process batch efficiently
            results = await self._process_batch_requests(batch)

            # Return results to callers
            for request, result in zip(batch, results):
                request.future.set_result(result)

        self.processing = False
```

### CPU Allocation Optimization

```yaml
# Allocate CPU only during request processing
metadata:
  annotations:
    run.googleapis.com/cpu-throttling: "true"  # Default

# For CPU-intensive background tasks
metadata:
  annotations:
    run.googleapis.com/cpu-throttling: "false"  # Always allocated
```

## Security Best Practices

### Binary Authorization

```yaml
apiVersion: binaryauthorization.grafeas.io/v1beta1
kind: Policy
metadata:
  name: binary-authorization-policy
spec:
  defaultAdmissionRule:
    requireAttestationsBy:
      - projects/PROJECT_ID/attestors/prod-attestor
  globalPolicyEvaluationMode: ENABLE
```

### Network Security

```yaml
# VPC Service Controls
apiVersion: accesscontextmanager.googleapis.com/v1
kind: ServicePerimeter
metadata:
  name: cloud-run-perimeter
spec:
  resources:
    - projects/PROJECT_NUMBER
  restrictedServices:
    - run.googleapis.com
    - secretmanager.googleapis.com
```

## GitHub Actions Integration

### Complete Deployment Workflow

```yaml
name: Deploy to Cloud Run

on:
  push:
    branches: [main, staging]

env:
  PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  SERVICE: backend
  REGION: us-central1

jobs:
  deploy:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      id-token: write

    steps:
      - uses: actions/checkout@v4

      - id: auth
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
          service_account: ${{ secrets.WIF_SA }}

      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v2

      - name: Build and Push
        run: |
          gcloud builds submit \
            --tag gcr.io/$PROJECT_ID/$SERVICE:$GITHUB_SHA \
            --gcs-log-dir gs://$PROJECT_ID-cloudbuild-logs

      - name: Deploy
        uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: ${{ env.SERVICE }}
          image: gcr.io/${{ env.PROJECT_ID }}/${{ env.SERVICE }}:${{ github.sha }}
          region: ${{ env.REGION }}
          flags: |
            --platform managed
            --allow-unauthenticated
            --min-instances 1
            --max-instances 100
            --memory 1Gi
            --cpu 1
            --timeout 300
            --concurrency 80
            --service-account ${{ secrets.SERVICE_ACCOUNT }}

      - name: Verify Deployment
        run: |
          URL=$(gcloud run services describe $SERVICE --region $REGION --format 'value(status.url)')
          curl -f $URL/health || exit 1
```

## References

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Container Runtime Contract](https://cloud.google.com/run/docs/container-contract)
- [Deployment Best Practices](https://cloud.google.com/run/docs/deploying)
- [Performance Optimization](https://cloud.google.com/run/docs/tips)
- [Security Best Practices](https://cloud.google.com/run/docs/securing)
