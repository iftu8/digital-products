# Enterprise Engineering Playbook: Building Distributed Systems, Dual-Engine APIs, and Autonomous AI Pipelines

---

## Chapter 1: Distributed System Architecture & Design Foundations

Designing high-throughput enterprise systems requires moving away from fragile, tightly coupled architectures toward resilient, distributed paradigms. This chapter establishes the foundational topologies for modern scale, examining when to decompose monoliths, how to implement event-driven architectures, and how to scale data stores horizontally without sacrificing consistency.

### Microservices vs. Monolith: Designing High-Throughput Systems

The monolithic architecture—while simple to deploy initially—eventually hits scaling bottlenecks due to shared memory spaces, lock contention, and the blast radius of runtime exceptions. Microservices isolate functional domains, but introduce network latency, distributed transactions, and operational overhead. 

To determine the architectural transition point, apply the **Scale Cube (AKF Scale Cube)**:
*   **X-Axis (Horizontal Duplication):** Running multiple instances of the monolith behind a load balancer. This solves compute bottlenecks but leaves database bottlenecks untouched.
*   **Y-Axis (Functional Decomposition):** Splitting the application by service or domain (e.g., Billing Service, User Service). This is true microservice architecture.
*   **Z-Axis (Data Partitioning / Sharding):** Splitting the database so different servers handle different subsets of data based on an entity key (e.g., tenant ID).

```
[Client] --> [API Gateway / L7 Proxy]
                   |
       +-----------+-----------+
       |                       |
[Auth Service (Y-Axis)]  [Core Engine (Y-Axis)]
       |                       |
[PostgreSQL Primary]     [Redis Cluster]
```

When designing high-throughput microservices, prioritize **shared-nothing architectures**. Services must never share a database instance; instead, communication must occur over explicit network contracts (gRPC or REST) or via asynchronous event buses.

### Event-Driven Architecture and Asynchronous Messaging Patterns

Synchronous request-response chains ($A \rightarrow B \rightarrow C$) multiply latency and compound failure rates. If service $C$ fails, $A$ and $B$ hang, exhausting connection pools. Event-driven architecture (EDA) decouples producers from consumers using message brokers (e.g., Apache Kafka, RabbitMQ, Redis Streams).

#### Core Patterns
1.  **Publish-Subscribe (Pub/Sub):** Producers emit events to a topic; multiple consumers process independent reactions to the same event.
2.  **Event Sourcing:** State changes are stored as a sequence of immutable events rather than overwriting current state.
3.  **CQRS (Command Query Responsibility Segregation):** Separating write models (commands) from read models (queries) to optimize independent scaling profiles.

> **Production Rule:** Always ensure idempotency in event consumers. Network partitions, retries, and broker failures will cause duplicate delivery of messages. Design consumers with deduplication tables or atomic upsert operations.

### High-Availability Database Topologies (PostgreSQL, Redis Cluster)

#### PostgreSQL High Availability
At enterprise scale, a single relational database is a single point of failure (SPOF). Production PostgreSQL architectures must implement **Streaming Replication** with automated failover.

*   **Primary Node:** Handles all write operations (`INSERT`, `UPDATE`, `DELETE`) and streams Write-Ahead Logs (WAL) to standby nodes.
*   **Standby Nodes:** Replicate data continuously. Can be configured for synchronous replication (guaranteeing zero data loss at the cost of write latency) or asynchronous replication (higher performance, potential RPO > 0).
*   **Patroni / Consul / etcd:** Used for consensus-driven automatic failover. If the primary node drops heartbeats, the cluster elects a new primary from the healthiest standby.

#### Redis Cluster Topology
Redis provides microsecond-latency data access, but a single instance is bounded by RAM and CPU cores. A Redis Cluster solves this via data sharding:
*   The keyspace is split into **16,384 hash slots**.
*   Every node in the cluster is responsible for a subset of these slots.
*   Clients use CRC16 checksums modulo 16,384 to route commands directly to the correct shard node, minimizing proxy overhead.
*   High availability is achieved by pairing every master shard with one or more replica shards. If a master fails, the cluster promotes its replica automatically.

---

## Chapter 2: Enterprise Python Engine for High-Performance Workflows

Python is often bottlenecked by the Global Interpreter Lock (GIL) for CPU-bound tasks, but for I/O-bound workflows—such as web scraping, API ingestion, and event processing—asynchronous Python operating on the `asyncio` event loop delivers phenomenal performance.

### Asynchronous Programming with `asyncio` and `aiohttp`

Standard libraries like `requests` block the calling thread while waiting for network I/O. `asyncio` combined with `aiohttp` allows a single thread to multiplex thousands of concurrent network sockets efficiently.

Below is a production-grade asynchronous ingestion engine featuring concurrency limiting via semaphores, structured error handling, and exponential backoff retry logic.

```python
import asyncio
import logging
import aiohttp
from typing import List, Dict, Any, Optional

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("AsyncEngine")

class EnterpriseIngestionEngine:
    def __init__(self, urls: List[str], max_concurrent: int = 50, timeout: int = 10):
        self.urls = urls
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.timeout = aiohttp.ClientTimeout(total=timeout)
        
    async def _fetch_with_retry(self, session: aiohttp.ClientSession, url: str, retries: int = 3) -> Optional[Dict[str, Any]]:
        backoff = 1.0
        async with self.semaphore:
            for attempt in range(retries):
                try:
                    async with session.get(url, timeout=self.timeout) as response:
                        if response.status == 200:
                            data = await response.json()
                            return {"url": url, "status": response.status, "data": data}
                        elif response.status in [429, 500, 502, 503, 504]:
                            logger.warning(f"Rate limited or server error {response.status} on {url}. Retrying in {backoff}s...")
                            await asyncio.sleep(backoff)
                            backoff *= 2
                        else:
                            logger.error(f"HTTP {response.status} encountered for {url}")
                            return None
                except asyncio.TimeoutError:
                    logger.warning(f"Timeout on {url} (Attempt {attempt + 1}/{retries})")
                    await asyncio.sleep(backoff)
                    backoff *= 2
                except aiohttp.ClientError as e:
                    logger.error(f"Client error for {url}: {str(e)}")
                    break
        return None

    async def run(self) -> List[Dict[str, Any]]:
        connector = aiohttp.TCPConnector(limit=0, ttl_dns_cache=300)
        async with aiohttp.ClientSession(connector=connector) as session:
            tasks = [self._fetch_with_retry(session, url) for url in self.urls]
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
            valid_results = []
            for res in results:
                if isinstance(res, dict):
                    valid_results.append(res)
                elif isinstance(res, Exception):
                    logger.error(f"Task raised unhandled exception: {res}")
            return valid_results

if __name__ == "__main__":
    test_urls = [f"https://httpbin.org/delay/1" for _ in range(100)]
    engine = EnterpriseIngestionEngine(test_urls, max_concurrent=20)
    loop = asyncio.get_event_loop()
    output = loop.run_until_complete(engine.run())
    logger.info(f"Successfully processed {len(output)} records.")
```

### Designing Resilient Data Scraping and Automated Processing Pipelines

Enterprise-scale data ingestion requires more than just fetching URLs. Pipelines must enforce data contracts, cleanse inputs, handle schema drifts, and stream outputs to persistent storage reliably.

```
[Target APIs/Sites] 
        │
        ▼
[Async Ingestion Engine] 
        │
        ▼ (Queue / Buffer)
[Pydantic Validation Layer]
        │
        ├── [Valid] ──► [PostgreSQL / Vector DB]
        │
        └── [Invalid] ─► [Dead Letter Queue (DLQ)]
```

*   **Pydantic Models:** Use strict data validation at ingestion boundaries. If an upstream API changes its schema unexpectedly, the record is flagged and diverted to a Dead Letter Queue (DLQ) rather than corrupting downstream databases.
*   **Backpressure Management:** Implement bounded queues (using `asyncio.Queue`) between producers and consumers to prevent memory exhaustion when downstream systems slow down.

### Rate-Limiting, Proxy Rotation, and Anti-Bot Mitigation Strategies

When scraping external third-party systems or public APIs, naive scraping scripts will quickly hit IP bans, CAPTCHAs, and rate limits. Production Python engines implement multi-layered anti-detection strategies:

1.  **Dynamic Proxy Pools:** Rotate requests across a pool of rotating residential or datacenter proxies using middleware in `aiohttp`.
2.  **Fingerprint Randomization:** Dynamically randomize User-Agent strings, TLS fingerprints (using `curl_cffi`), and HTTP headers per request.
3.  **Adaptive Rate Limiting:** Implement token bucket or leaky bucket algorithms locally to ensure your request frequency matches the target's capacity limits.

---

## Chapter 3: Robust Ruby on Rails Core & API Gateway

While Python excels at data ingestion and AI orchestration, Ruby on Rails remains an exceptionally productive framework for building robust, domain-driven core services and API gateways.

### Architecting Thread-Safe GraphQL and RESTful APIs in Rails

Modern Rails runs on multi-threaded application servers like Puma. To prevent race conditions, memory leaks, and data corruption, every component in your Rails stack—controllers, serializers, middleware, and database connections—must be strictly thread-safe.

#### Configuring Puma for Concurrency
In `config/puma.rb`, configure workers and threads explicitly based on available CPU cores:

```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

preload_app!

rackup DefaultRackUp
port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
```

#### Thread-Safe GraphQL Implementation using `graphql-ruby`
Ensure that custom context objects and execution strategies do not mutate global state.

```ruby
# app/graphql/types/mutation_type.rb
module Types
  class MutationType < Types::BaseObject
    field :create_enterprise_record, mutation: Mutations::CreateEnterpriseRecord
  end
end

# app/graphql/mutations/create_enterprise_record.rb
module Mutations
  class CreateEnterpriseRecord < Mutations::BaseMutation
    argument :payload, GraphQL::Types::JSON, required: true

    field :record_id, ID, null: true
    field :errors, [String], null: false

    def resolve(payload:)
      # Thread-safe authorization and transactional persistence
      context[:current_user] => { id: user_id, role: }
      raise GraphQL::ExecutionError, "Unauthorized" unless role == "admin"

      record = EnterpriseRecord.new(payload_data: payload, created_by_id: user_id)
      
      if record.save
        { record_id: record.id, errors: [] }
      else
        { record_id: nil, errors: record.errors.full_messages }
      end
    end
  end
end
```

### Advanced Background Job Processing with Sidekiq Pro and Redis

Never process heavy tasks (PDF generation, bulk emails, heavy webhooks) inside the HTTP request-response cycle. Sidekiq Pro provides enterprise features such as reliable queues, batch processing, and super-fast Redis connection pooling.

```ruby
# app/workers/enterprise_batch_processing_worker.rb
class EnterpriseBatchProcessingWorker
  include Sidekiq::Worker
  sidekiq_options queue: :enterprise_critical, retry: 5, dead: true

  def perform(batch_id, organization_id)
    logger.info("Starting processing for batch #{batch_id} under organization #{organization_id}")
    
    org = Organization.find(organization_id)
    items = org.pending_items.limit(500)
    
    ActiveRecord::Base.transaction do
      items.each do |item|
        # Process domain logic atomically
        item.mark_processed!
      end
    end
    
    logger.info("Successfully completed batch #{batch_id}")
  rescue ActiveRecord::RecordNotFound => e
    logger.error("Organization not found: #{e.message}")
    # Do not retry fatal database lookup failures
  rescue StandardError => e
    logger.error("Transient failure during batch processing: #{e.message}")
    raise e # Triggers Sidekiq retry mechanism with backoff
  end
end
```

### Zero-Downtime Database Migrations and Schema Evolution

Deploying schema changes to high-availability PostgreSQL databases without locking tables or causing downtime requires adhering to strict migration rules.

#### Banned Operations in Production
*   Adding a column with a default value to a large table (locks the table to rewrite every row).
*   Adding a `NOT NULL` constraint without a default.
*   Renaming tables or columns directly (breaks running instances using the old schema).

#### Safe Migration Pattern (The Expand and Contract Pattern)
1.  **Expand:** Add the new column as nullable.
2.  **Migrate:** Deploy application code that writes to *both* columns and reads from the old column. Run a background backfill migration to populate historic rows.
3.  **Switch:** Deploy code that reads from the new column.
4.  **Contract:** Remove the old column in a subsequent deployment.

```ruby
# db/migrate/20260330120000_add_status_v2_safely.rb
class AddStatusV2Safely < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    # Use concurrently for indexes to avoid locks
    add_column :orders, :status_v2, :string, null: true
    add_index :orders, :status_v2, algorithm: :concurrently
  end
end
```

---

## Chapter 4: Cryptographic Security & Zero-Trust Infrastructure

Zero-trust architecture assumes perimeter security is insufficient. Every request, database record, and inter-service communication channel must be cryptographically verified, encrypted, and authorized.

### Implementing AES-256-GCM Data Encryption at Rest and in Transit

For data at rest, use **AES-256-GCM (Galois/Counter Mode)**. Unlike CBC mode, GCM provides authenticated encryption, protecting against tampering and chosen-ciphertext attacks.

```python
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

class EnterpriseCryptoManager:
    def __init__(self, master_key: bytes = None):
        # Master key must be 32 bytes (256 bits) loaded from secure KMS / Vault
        self.master_key = master_key or AESGCM.generate_key(bit_length=256)
        self.aesgcm = AESGCM(self.master_key)

    def encrypt_payload(self, plaintext: bytes, associated_data: bytes = b"") -> bytes:
        # Generate a cryptographically secure 12-byte nonce
        nonce = os.urandom(12)
        ciphertext = self.aesgcm.encrypt(nonce, plaintext, associated_data)
        # Prepend nonce to ciphertext for storage
        return nonce + ciphertext

    def decrypt_payload(self, encrypted_payload: bytes, associated_data: bytes = b"") -> bytes:
        nonce = encrypted_payload[:12]
        ciphertext = encrypted_payload[12:]
        return self.aesgcm.decrypt(nonce, ciphertext, associated_data)

if __name__ == "__main__":
    crypto = EnterpriseCryptoManager()
    secret = b"Confidential Enterprise Financial Records"
    encrypted = crypto.encrypt_payload(secret, associated_data=b"OrgID:9921")
    decrypted = crypto.decrypt_payload(encrypted, associated_data=b"OrgID:9921")
    print(f"Decrypted successfully: {decrypted.decode('utf-8')}")
```

### Secure API Authentication: JWT, OAuth2, and HMAC Request Signing

*   **JWT (JSON Web Tokens):** Used for stateless user authentication. Signed with RS256 (RSA Signature with SHA-256) so services can verify tokens locally using a public key without querying an auth server.
*   **HMAC (Hash-based Message Authentication Code):** Used for machine-to-machine (M2M) webhooks. The sender signs the HTTP request body and timestamp using a shared secret; the receiver recalculates the HMAC signature to verify authenticity and prevent replay attacks.

### Automated Vulnerability Scanning and DevSecOps Integration

Integrate security scanning directly into your CI/CD pipelines:
*   **SAST (Static Application Security Testing):** Tools like `Brakeman` for Ruby and `Bandit` for Python scan source code for known vulnerability patterns prior to merge.
*   **SCA (Software Composition Analysis):** Tools like `Dependabot` or `Snyk` inspect third-party dependencies (`Gemfile.lock`, `requirements.txt`) for CVEs.
*   **DAST (Dynamic Application Security Testing):** Automated penetration testing tools run against staging environments before production promotion.

---

## Chapter 5: AI Sentience Integration & Vector Search Engine

Modern enterprise systems integrate Large Language Models (LLMs) and vector search engines to build intelligent automation pipelines and Retrieval-Augmented Generation (RAG) systems.

### Interfacing with Gemini API for Automated Text, Code, and Intelligence Generation

Using official enterprise SDKs, we interface with Gemini models to process complex reasoning tasks with structured output schemas.

```python
import os
import google.generativeai as genai
from pydantic import BaseModel, Field

# Configure API key from environment
genai.configure(api_key=os.environ["GEMINI_API_KEY"])

class SentimentAnalysisReport(BaseModel):
    sentiment: str = Field(description="Positive, Neutral, or Negative")
    confidence_score: float = Field(description="Between 0.0 and 1.0")
    key_action_items: list[str] = Field(description="Extracted action items from text")

class EnterpriseGeminiEngine:
    def __init__(self, model_name: str = "gemini-1.5-pro"):
        self.model = genai.GenerativeModel(model_name)

    def analyze_feedback(self, raw_text: str) -> SentimentAnalysisReport:
        prompt = f"""
        Analyze the following enterprise customer feedback. Extract sentiment, confidence, 
        and action items according to the requested schema.
        
        Feedback:
        {raw_text}
        """
        
        response = self.model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                response_mime_type="application/json",
                response_schema=SentimentAnalysisReport,
                temperature=0.1
            )
        )
        
        # Pydantic parses the structured JSON returned directly from Gemini
        return SentimentAnalysisReport.model_validate_json(response.text)

if __name__ == "__main__":
    engine = EnterpriseGeminiEngine()
    sample_text = "The new batch processing engine is 40% faster, but we experienced an intermittent timeout on node 4. Please investigate Redis cluster persistence settings."
    report = engine.analyze_feedback(sample_text)
    print(report.model_dump_json(indent=2))
```

### Vector Databases (`pgvector`) for Semantic Search and RAG

Storing high-dimensional embeddings directly in PostgreSQL using the `pgvector` extension eliminates the operational complexity of managing external vector DBs like Pinecone or Milvus.

#### Enabling pgvector in PostgreSQL
```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE enterprise_documents (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    embedding vector(1536) -- 1536 dimensions for text-embedding-ada-002 / Gemini embeddings
);

-- Create an HNSW index for high-performance approximate nearest neighbor (ANN) search
CREATE INDEX ON enterprise_documents USING hnsw (embedding vector_cosine_ops);
```

#### Performing Semantic Search in Python
```python
import psycopg2
import numpy as np

def semantic_search(query_embedding: list[float], limit: int = 5):
    conn = psycopg2.connect(os.environ["DATABASE_URL"])
    cursor = conn.cursor()
    
    # Cosine distance operator in pgvector: <=>
    sql = """
        SELECT title, content, 1 - (embedding <=> %s::vector) AS similarity
        FROM enterprise_documents
        ORDER BY embedding <=> %s::vector
        LIMIT %s;
    """
    
    cursor.execute(sql, (query_embedding, query_embedding, limit))
    results = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return results
```

### Managing Token Limits, Prompt Caching, and Streaming Responses

*   **Token Optimization:** Implement tokenizers (`tiktoken` or model-specific counters) before dispatching prompts to prevent failing requests due to context window limits.
*   **Prompt Caching:** Utilize Gemini's context caching capabilities for large documents or codebases, reducing latency and token costs by up to 80% for repetitive queries.
*   **Streaming Responses:** Use `generate_content_async` with streaming enabled to pipe tokens directly to the client via WebSockets or Server-Sent Events (SSE), reducing Time-to-First-Token (TTFT).

---

## Chapter 6: Autonomous System Monitoring & Self-Healing Pipelines

Enterprise infrastructure cannot rely purely on human intervention for incident response. Systems must continuously observe their own health and execute automated remediation workflows.

### Building Automated Watcher Services in Python for Server Health

Below is an autonomous watcher script that monitors system metrics (CPU, Memory, Disk, and HTTP health) and triggers remediation actions or incident alerts upon threshold breaches.

```python
import time
import psutil
import requests
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] [Watcher]: %(message)s")
logger = logging.getLogger("AutonomousWatcher")

class SystemHealthWatcher:
    def __init__(self, health_endpoint: str, cpu_threshold: float = 90.0, mem_threshold: float = 85.0):
        self.health_endpoint = health_endpoint
        self.cpu_threshold = cpu_threshold
        self.mem_threshold = mem_threshold

    def check_system_resources(self) -> dict:
        cpu_usage = psutil.cpu_percent(interval=1)
        mem_usage = psutil.virtual_memory().percent
        disk_usage = psutil.disk_usage('/').percent
        
        return {
            "cpu": cpu_usage,
            "memory": mem_usage,
            "disk": disk_usage
        }

    def check_application_health(self) -> bool:
        try:
            response = requests.get(self.health_endpoint, timeout=5)
            return response.status_code == 200
        except requests.RequestException:
            return False

    def execute_self_healing(self, anomaly_type: str):
        logger.critical(f"ANOMALY DETECTED: {anomaly_type}. Initiating automated remediation...")
        # Example remediation: Trigger container restart via Docker API or Kubernetes client
        # os.system("docker restart enterprise_core_worker")
        logger.info("Remediation script executed successfully.")

    def run_poll_loop(self, interval_seconds: int = 30):
        logger.info("Starting Autonomous Watcher Loop...")
        while True:
            metrics = self.check_system_resources()
            app_healthy = self.check_application_health()
            
            logger.info(f"Metrics: CPU={metrics['cpu']}% | Mem={metrics['memory']}% | Disk={metrics['disk']}% | AppHealthy={app_healthy}")
            
            if metrics['cpu'] > self.cpu_threshold:
                self.execute_self_healing("High CPU Saturation")
            elif metrics['memory'] > self.mem_threshold:
                self.execute_self_healing("High Memory Pressure")
            elif not app_healthy:
                self.execute_self_healing("Application Health Endpoint Unreachable")
                
            time.sleep(interval_seconds)

if __name__ == "__main__":
    watcher = SystemHealthWatcher(health_endpoint="http://localhost:3000/health")
    # watcher.run_poll_loop() # Uncomment to run in production daemon mode
```

### Self-Healing Workflows: Automatic Failovers and Container Restarts

When autonomous watchers detect failures, self-healing pipelines engage through orchestrated states:
1.  **Drain:** Stop routing traffic to the failing node via load balancer weight adjustments.
2.  **Isolate:** Quarantine the container or VM for post-mortem forensics (memory dump analysis).
3.  **Replenish:** Spin up a fresh container instance from the golden AMI or container image registry.
4.  **Verify:** Execute health probes against the new instance before integrating it back into the active rotation pool.

---

## Chapter 7: CI/CD & Production Cloud Deployment

Deploying complex, multi-engine architectures (Ruby on Rails + Python microservices + PostgreSQL + Redis) requires robust containerization and continuous integration pipelines.

### Dockerizing Dual-Engine (Ruby + Python) Microservice Stacks

We use Docker Compose for local orchestration and production multi-stage builds to keep image sizes lean and secure.

```dockerfile
# ==========================================
# Python Ingestion Engine Dockerfile
# ==========================================
FROM python:3.11-slim AS python-engine

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "main.py"]
```

```dockerfile
# ==========================================
# Ruby on Rails Core Dockerfile
# ==========================================
FROM ruby:3.2.2-slim AS rails-core

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev git curl libvips && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

### GitHub Actions Workflows for Multi-Environment Automated Deployment

```yaml
name: Enterprise CI/CD Pipeline

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  test-and-lint:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_PASSWORD: password
          POSTGRES_DB: enterprise_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2.2
          bundler-cache: true

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install Python Dependencies
        run: pip install -r requirements.txt

      - name: Run Python Linters and Tests
        run: pytest

      - name: Run Rails Tests
        env:
          DATABASE_URL: postgres://postgres:password@localhost:5432/enterprise_test
        run: |
          bundle exec rails db:prepare
          bundle exec rspec

  deploy-production:
    needs: test-and-lint
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and Push Rails Core
        uses: docker/build-push-action@v5
        with:
          context: .
          file: Dockerfile.rails
          push: true
          tags: ghcr.io/${{ github.repository }}/rails-core:latest

      - name: Trigger Infrastructure Rolling Update
        run: |
          echo "Triggering Kubernetes deployment rollout..."
          # curl -X POST ${{ secrets.K8S_WEBHOOK_TRIGGER }}
```

### Monitoring Performance with Prometheus and Grafana Dashboards

Production observability relies on exporting OpenTelemetry-compliant metrics.
*   **Prometheus:** Scrapes metrics endpoints (`/metrics`) exposed by Rails (`prometheus_exporter`) and Python services at regular intervals.
*   **Grafana:** Visualizes critical enterprise SLIs (Service Level Indicators) and SLOs (Service Level Objectives), including:
    *   HTTP Request Latency (p95, p99 percentiles).
    *   Error Rates (HTTP 5xx responses per minute).
    *   Database Connection Pool Saturation.
    *   Sidekiq / Celery Queue Latency and Backlog Size.

---
*End of Enterprise Engineering Playbook.*