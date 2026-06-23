# The Nexus AI & Ruby Core Ecosystem

### The ultimate hyper-scalable enterprise bridge uniting high-concurrency Ruby orchestration engines with state-of-the-art Python artificial intelligence systems, real-time advanced automation workflows, and distributed agentic mesh networks.

![Build Status](https://img.shields.io/github/actions/workflow/status/nexus-ai/nexus-core/ci.yml?branch=main&style=for-the-badge)
![License](https://img.shields.io/github/license/nexus-ai/nexus-core?style=for-the-badge)
![Version](https://img.shields.io/github/v/release/nexus-ai/nexus-core?style=for-the-badge)
![Ruby Version](https://img.shields.io/badge/Ruby-3.3%2B-red?style=for-the-badge&logo=ruby)
![Python Version](https://img.shields.io/badge/Python-3.11%2B-blue?style=for-the-badge&logo=python)

---

## Table of Contents

- [1. Hero Section](#the-nexus-ai--ruby-core-ecosystem)
- [2. System Architecture](#system-architecture)
  - [2.1 The Concurrency Layer (Ruby Core)](#21-the-concurrency-layer-ruby-core)
  - [2.2 The Intelligence Engine (Python Subsystem)](#22-the-intelligence-engine-python-subsystem)
  - [2.3 High-Performance Communication Protocol](#23-high-performance-communication-protocol)
- [3. Installation & Setup](#installation--setup)
  - [3.1 Prerequisites](#31-prerequisites)
  - [3.2 Repository Cloning & Environment Isolation](#32-repository-cloning--environment-isolation)
  - [3.3 Ruby Dependency Resolution](#33-ruby-dependency-resolution)
  - [3.4 Python Dependency Resolution](#34-python-dependency-resolution)
  - [3.5 Environmental Variable Configuration](#35-environmental-variable-configuration)
- [4. Advanced Usage & CLI Commands](#advanced-usage--cli-commands)
  - [4.1 Command 1: Deploying the Orchestrator with Dynamic Telemetry](#41-command-1-deploying-the-orchestrator-with-dynamic-telemetry)
  - [4.2 Command 2: Invoking Deep Cognitive Inference via Ruby Client](#42-command-2-invoking-deep-cognitive-inference-via-ruby-client)
  - [4.3 Command 3: Execution of the Distributed Agentic Sync Pipeline](#43-command-3-execution-of-the-distributed-agentic-sync-pipeline)
- [5. API & Module Reference](#api--module-reference)
- [6. Security Policy](#security-policy)
- [7. Contributing & License](#contributing--license)
  - [7.1 Contribution Guidelines](#71-contribution-guidelines)
  - [7.2 Licensing Framework](#72-licensing-framework)

---

## System Architecture

The Nexus AI & Ruby Core Ecosystem is engineered to bridge the performance gap between elegant rapid application development systems and intensive mathematical computation workloads. Rather than forcing a single language into spaces where it is sub-optimal, Nexus separates concerns across two highly optimized micro-runtimes.

```
       +-----------------------------------------------------------+
       |                  CLIENTS / API GATEWAY                    |
       +-----------------------------------------------------------+
                                     | (HTTPS / WSS)
                                     v
+-------------------------------------------------------------------------+
|                         RUBY CORE ORCHESTRATOR                          |
|                                                                         |
|  +------------------------+  +-------------------+  +----------------+  |
|  |   Puma / Falcon Web    |  |  Fiber-Scheduler  |  |   Sidekiq /    |  |
|  |     Server (HTTP)      |  |   (Async IO)      |  |  Solid Queue   |  |
|  +------------------------+  +-------------------+  +----------------+  |
+-------------------------------------------------------------------------+
       |                                                             ^
       | (gRPC / Protocol Buffers)                                   | (Events / PubSub)
       v                                                             v
+-------------------------------------------------------------------------+
|                          REDIS EVENT BROKER                             |
|             (Shared Memory, State Sync, Task Queue, Cache)              |
+-------------------------------------------------------------------------+
       ^                                                             ^
       | (IPC / Unix Sockets)                                        | (Data Streaming)
       v                                                             v
+-------------------------------------------------------------------------+
|                        PYTHON INTELLIGENCE ENGINE                       |
|                                                                         |
|  +------------------------+  +-------------------+  +----------------+  |
|  |      gRPC Server       |  |   PyTorch / ML    |  |   LangChain /  |  |
|  |     (Asyncio)          |  |  Inference Core   |  | Agentic Engine |  |
|  +------------------------+  +-------------------+  +----------------+  |
+-------------------------------------------------------------------------+
```

### 2.1 The Concurrency Layer (Ruby Core)

At the front-line of the Nexus Ecosystem lies the Ruby Core. Built atop modern Ruby 3.3+ constructs, this module takes full advantage of Non-blocking Fiber Schedulers and Ractors to process incoming network traffic, manage active user sessions, and parse complex webhooks. Ruby’s expressive metaprogramming capabilities are used to dynamically map database records, coordinate state machines, and dispatch jobs to asynchronous backends like Sidekiq and Solid Queue. 

By leveraging native C-extensions and specialized concurrency paradigms, the Ruby Core acts as a highly efficient traffic controller, ensuring zero-latency request handling while offloading long-running, CPU-bound machine learning tasks.

### 2.2 The Intelligence Engine (Python Subsystem)

While Ruby excels at lifecycle management and asynchronous system I/O, the Python Subsystem serves as the raw, mathematical engine of the architecture. Leveraging optimized execution frameworks such as PyTorch, ONNX Runtime, and Hugging Face Transformers, this layer processes deep cognitive tasks, predictive neural modeling, vector database indexing, and complex data pipeline cleaning.

The Python processes run inside sandboxed daemon containers or dedicated worker processes that monitor local UNIX sockets and distributed queues. This ensures that memory leaks or high-CPU workloads typical of transformer models never degrade the responsiveness of the public-facing Ruby APIs.

### 2.3 High-Performance Communication Protocol

Bi-directional communication between Ruby and Python is achieved through a multi-channel architecture designed for minimum serialization overhead:
- **Control Plane (gRPC & Protocol Buffers):** High-priority instructions, metadata validation, and direct model configuration calls use gRPC over HTTP/2. This guarantees strict typing, multiplexing, and low latency.
- **Data Plane (Redis Pub/Sub & Shared Memory):** Large datasets, image payloads, and bulk vector inputs are passed using serialized MessagePack arrays directly into Redis. Redis keys are then passed to the target processes, minimizing memory duplication across system boundaries.

---

## Installation & Setup

This guide walks through setting up the Nexus AI & Ruby Core Ecosystem in an isolated development or staging environment.

### 3.1 Prerequisites

Ensure your host machine has the following packages installed:
- **Ruby:** 3.3.0 or higher (configured via `rbenv`, `rvm`, or `chruby`)
- **Python:** 3.11.x or 3.12.x (configured via `pyenv` or `conda`)
- **Redis Server:** 7.2+ (running locally or accessible via network)
- **Compilers:** `gcc`, `g++`, `make` (for compiling native extensions)
- **OpenSSL:** 3.0+

### 3.2 Repository Cloning & Environment Isolation

Clone the repository and enter the workspace directory:

```bash
git clone https://github.com/nexus-ai/nexus-core.git
cd nexus-core
```

Initialize your environment files:

```bash
cp .env.example .env
```

### 3.3 Ruby Dependency Resolution

Use Bundler to resolve and compile the required Ruby gems. It is recommended to isolate gems to the local project path:

```bash
bundle config set --local path 'vendor/bundle'
bundle install --jobs=4 --retry=3
```

Verify the Ruby configuration and native bindings:

```bash
bundle exec ruby -e "require 'grpc'; puts 'gRPC Core loaded successfully!'"
```

### 3.4 Python Dependency Resolution

Create a dedicated virtual environment to prevent package drift and namespace collision with global packages:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
```

Verify PyTorch or your local acceleration (such as CUDA or Apple Silicon Metal) compile flags:

```bash
python3 -c "import torch; print('CUDA Available:', torch.cuda.is_available())"
```

### 3.5 Environmental Variable Configuration

Open your `.env` file and configure the essential ecosystem coordinates:

```ini
# --- Core Nexus Configuration ---
NEXUS_ENV=development
NEXUS_LOG_LEVEL=info
NEXUS_SECRET_KEY_BASE=dfa7101bb053bf9df0059e35b719ba195bb2101

# --- Microservice Bindings ---
NEXUS_RUBY_PORT=3000
NEXUS_PYTHON_PORT=50051
NEXUS_REDIS_URL=redis://localhost:6379/0

# --- Advanced AI API Integrations ---
OPENAI_API_KEY=sk-proj-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ANTHROPIC_API_KEY=sk-ant-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
HUGGINGFACE_API_TOKEN=hf_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# --- Threading & Concurrency ---
RUBY_MAX_THREADS=16
PYTHON_WORKER_CONCURRENCY=8
```

---

## Advanced Usage & CLI Commands

The Nexus Ecosystem comes packaged with a robust CLI framework allowing system administrators, operations engineers, and developers to manage, inspect, and execute complex workflows.

### 4.1 Command 1: Deploying the Orchestrator with Dynamic Telemetry

Start the Nexus engine with structured, high-resolution instrumentation enabled. This spawns the Puma/Falcon web application, registers active Sidekiq handlers, and establishes a secure connection to the Python gRPC daemon.

```bash
bundle exec bin/nexus start --telemetry --workers=4 --port=3000
```

Expected stdout output:

```text
[2026-03-31T08:42:01.129Z] INFO  -- NexusCore::Orchestrator: Initializing Nexus v4.2.0-RC1
[2026-03-31T08:42:01.130Z] INFO  -- NexusCore::Orchestrator: Binding Web Gateway to port 3000
[2026-03-31T08:42:01.245Z] INFO  -- NexusCore::Orchestrator: Fiber Scheduler configured with 1024 concurrent green threads
[2026-03-31T08:42:01.890Z] INFO  -- NexusCore::Orchestrator: Establishing connection to Python AI Engine [127.0.0.1:50051]
[2026-03-31T08:42:02.411Z] INFO  -- NexusCore::Orchestrator: Channel connected. gRPC handshake latency: 4.12ms
[2026-03-31T08:42:02.412Z] SUCCESS -- NexusCore::Orchestrator: System health check returned: 200 OK
```

### 4.2 Command 2: Invoking Deep Cognitive Inference via Ruby Client

You can run a model prediction or classification pipeline directly from your shell by triggering a synchronous loop execution that loads a dataset and runs it through the Python-side PyTorch transformers.

```bash
bundle exec bin/nexus run inference --model-name="bert-base-uncased" --payload="Analyze sentiment: 'Nexus AI platform has outstanding throughput and stability.'"
```

Expected JSON response from the command:

```json
{
  "status": "success",
  "execution_time_ms": 14.89,
  "payload": {
    "model": "bert-base-uncased",
    "predictions": [
      {
        "label": "POSITIVE",
        "confidence": 0.9984102249145508
      }
    ],
    "telemetry": {
      "python_runtime_v": "3.11.5",
      "gpu_accelerator_active": true,
      "memory_usage_bytes": 104857600
    }
  }
}
```

### 4.3 Command 3: Execution of the Distributed Agentic Sync Pipeline

To trigger background multi-agentic synchronization (where multiple autonomous Python workers discuss a task and output structural steps back to the Ruby PostgreSQL layer), run:

```bash
bundle exec bin/nexus agentic-sync --domain="financial-risk-analysis" --depth=high
```

Console Output Trace:

```text
================================================================================
NEXUS DISTRIBUTED AGENTIC WORKFLOW RUNNER
================================================================================
Domain: financial-risk-analysis | Search Depth: high | Timeout: 300s
--------------------------------------------------------------------------------
-> Initiating Agent 1: DataHarvestingAgent (Python) -> Collecting public filings...
   [Success] Retrieved 47 filings in 1.1s. Stashed payload to Redis Key: 'nexus:sec:tmp:994'
-> Triggering Agent 2: SynthesisAgent (Ruby) -> Generating contextual embeddings...
   [Success] Normalized 12,000 tabular structures inside Ractor thread pools.
-> Spawning Agent 3: CriticAgent (Python/PyTorch) -> Run vulnerability assessment...
   [Analysis Completed] Detected 2 anomaly spikes inside the Q3 revenue metrics.
-> Saving consolidated analytical packet to database store via ActiveRecord...
================================================================================
Result Payload written to: db/reports/financial-risk-analysis-2026-03-31.json
================================================================================
```

---

## API & Module Reference

Below is a tabular list outlining the key interfaces in the Nexus Core framework. These classes can be found under the `lib/` directory in Ruby and `src/` directory in Python.

| Module Namespace | Primary Class / Endpoint | Interface Functions | Core Purpose |
| :--- | :--- | :--- | :--- |
| `NexusCore` | `NexusCore::Orchestrator` | `.initialize_pool(size)`<br>`.dispatch(payload)`<br>`.shutdown!` | Standardizes thread allocation, manages the dynamic gRPC pool, and orchestrates life-cycles. |
| `AegisPredict` | `AegisPredict::InferenceEngine` | `.load_model(uri)`<br>`.predict(features)`<br>`.unload()` | Operates inside the Python process to safely boot neural networks and execute mathematical transformations. |
| `NexusCore` | `NexusCore::AutomationEngine` | `.register_trigger(event)`<br>`.fire_action(action_id)` | Configurable YAML-based engine designed to execute automated scripts and fire webhooks on specific events. |
| `AegisPredict` | `AegisPredict::AnomalyDetector` | `.stream_ingest(data_chunk)`<br>`.get_outliers()` | Continuously monitors real-time operational streams and points out multi-dimensional telemetry spikes. |

---

## Security Policy

We take the security of the Nexus AI & Ruby Core Ecosystem seriously. If you discover any potential vulnerabilities, resource-exhaustion issues, or security flaws, please refer immediately to our specialized [SECURITY.md](SECURITY.md) guidelines file in this repository.

> **CRITICAL WARNING:** Do not open GitHub issues for suspected security bugs or leak active access tokens. Instead, follow the coordinated disclosure protocols detailed in our security guidelines to ensure a secure, patched release cycle is maintained.

---

## Contributing & License

We love receiving contributions from the global engineering community! To keep quality exceptionally high, please adhere to our pipeline expectations.

### 7.1 Contribution Guidelines

1. **Fork the Repository:** Create your own feature branch named `feature/your-glorious-improvement` or `bugfix/issue-identifier`.
2. **Lint and Format:** 
   - Ensure Ruby files adhere to standard styles by running: `bundle exec rubocop -a`.
   - Ensure Python code adheres to strict PEP-8 standards by running: `black . && flake8`.
3. **Write Unit Tests:**
   - Write comprehensive tests inside the `spec/` folder for Ruby (using RSpec) and the `tests/` folder for Python (using PyTest).
   - Ensure your updates achieve a coverage threshold of at least 90%.
4. **Submit a Pull Request:** Detail your structural changes and list the issue tickets being resolved. Provide clear reproduction steps.

### 7.2 Licensing Framework

This software is distributed under the terms of the **MIT License**.

```text
Copyright (c) 2026 The Nexus AI & Ruby Core Ecosystem Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.