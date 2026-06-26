# 📑 Contributing to Nexus Ecosystem & SOP Guidelines

![SOP](https://img.shields.io/badge/SOP-STRICT-FF0000?style=for-the-badge&labelColor=141321)
![Contributions](https://img.shields.io/badge/CONTRIBUTIONS-WELCOME-00FF9D?style=for-the-badge&labelColor=141321)
![Security](https://img.shields.io/badge/SECURITY-MAXIMUM-00E5FF?style=for-the-badge&labelColor=141321)

Thank you for entering the Nexus Core. To maintain the structural integrity of our autonomous workflows, high-concurrency Ruby services, and generative AI pipelines, all contributors (including automated agents) must strictly adhere to this Standard Operating Procedure (SOP).

---

## 📋 Table of Contents
1. [Architecture Bootup (Local Setup)](#-1-architecture-bootup-local-setup)
2. [The Core Workflow SOP](#-2-the-core-workflow-sop)
3. [Commit Message Standards](#-3-commit-message-standards)
4. [Architectural Code Standards](#-4-architectural-code-standards)
5. [Pull Request (PR) Integration](#-5-pull-request-pr-integration)
6. [Feline Exception Protocol (FEP)](#-6-feline-exception-protocol-fep)

---

## 💻 1. Architecture Bootup (Local Setup)

Before contributing, ensure your local terminal is synchronized with the Nexus Core telemetry:

* **Ruby Environment:** Requires Ruby 3.3+. Run `bundle install` to align core dependencies.
* **Python & AI Nodes:** Requires Python 3.10+. Use Conda or standard VENV. Run `pip install -r requirements.txt`.
* **Secrets Management:** **NEVER** push `.env` files. Use the `.env.example` template to configure local Gemini API keys and Database URIs.

---

## 🚀 2. The Core Workflow SOP

We operate on a **Zero-Touch CI/CD Workflow Mesh**. Direct pushes to the `master`/`main` branch are strictly prohibited by GitHub branch protection rules.

```mermaid
sequenceDiagram
    autonumber
    actor Dev as Contributor / AI Agent
    participant Repo as GitHub Repository
    participant Actions as Nexus CI/CD (Actions)
    
    Dev->>Repo: 1. Open Issue [SYSTEM-TRIGGER]
    Dev->>Dev: 2. git checkout -b feature/module-name
    Dev->>Repo: 3. Push Branch & Open PR
    Repo->>Actions: 4. Trigger Telemetry & Linter Scans
    Actions-->>Repo: 5. Approval (Green Build)
    Repo->>Repo: 6. Merge to Main & Auto-Deploy
📝 3. Commit Message Standards
We strictly follow the Conventional Commits methodology to allow automated semantic versioning and changelog generation:
feat: A new feature or AI prompt module addition.
fix: A bug resolution in the Ruby/Python backend.
docs: Updates to the Wiki, Readme, or Markdown vaults.
chore: Pipeline maintenance (GitHub Actions, Makefiles, dependency updates).
refactor: Structural code improvements without changing functionality.
Example: feat(ai-router): implement Gemini fallback generation protocol
💎 4. Architectural Code Standards
To keep the codebase highly optimized and production-ready:
🔴 Ruby Core Infrastructure
All modules must explicitly include # frozen_string_literal: true at the top of the file to preserve memory alignment.
Code must pass standard RuboCop linting without critical warnings.
Keep controllers lean; offload heavy async computations to specialized background worker daemons.
🔵 Python & AI Kernel Components
Scripts running prediction models or automated tasks must incorporate explicit timeout handling to avoid hanging processes.
Code must be formatted using Black and follow PEP-8 standards.
Avoid infinite API loops; implement exponential backoff for third-party LLM rate limits.
🔄 5. Pull Request (PR) Integration
When submitting a PR, ensure the following automated checklist is completed:
[ ] Linked Issue: The PR must link to an active issue (e.g., Closes #12).
[ ] Passing Telemetry: The internal workflow runner must clear all build jobs without unexpected compilation timeouts.
[ ] No Secrets Exposed: Ensure no API keys or personal access tokens (PATs) are hardcoded.
[ ] Documentation Updated: If architectural boundaries were changed, update the Wiki accordingly.
🐈 6. Feline Exception Protocol (FEP)
Given that runtime stability is consistently subject to Feline Disruption Events (FDE), all engineers must prepare for external physical keyboard interference:
CRITICAL ALERT: IF "Syntax Error" (The Cat) steps on physical deployment hardware:
   1. Immediately halt all ongoing production merges.
   2. Deploy tactical snack packages to clear the desktop console area.
   3. Force-refresh the local terminal status using: git system-rest-easy
   4. Resume deployment loop once console homeostasis is restored.
<div align="center">
<i>"Engineering logic. Automating chaos. Zero-Touch ecosystem."</i>
</div>
