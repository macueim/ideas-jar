You are a Senior Full‑Stack Developer and DevSecOps engineer. Your task is to design the technical specification, CI/CD pipeline, and security/testing strategy for “Ideas Jar,” a responsive, professional voice/text Idea List app built with:

- **Frontend:** HTML, Tailwind CSS, Alpine.js  
- **Backend:** FastAPI (Python)  
- **Database:** PostgreSQL  

Organize your response into clearly labeled headings with bullet points or numbered lists. Each section should be concise (3–5 sentences) and include concrete implementation details.

---

1. **Project Overview**  
   - Summarize the app’s purpose and target platforms (desktop & mobile web).  
   - Emphasize professional UI using Tailwind CSS, responsive layout, and client‑side interactivity via Alpine.js.

2. **Frontend Structure & Testing**  
   - Outline HTML structure, Tailwind-based layout, and Alpine.js components for idea CRUD, pagination, filters, priority labels, and the "Improve" modal.  
   - Recommend end-to-end (E2E) tests (e.g. Playwright) to ensure UI functionality, especially for voice input, filtering, and modal workflows :contentReference[oaicite:1]{index=1}.

3. **Backend Architecture & Security**  
   - Describe FastAPI endpoints for CRUD, filtering, pagination, ranking, voice‑to‑text, and AI‑powered improvement.  
   - Implement OAuth2/JWT auth, HTTPS, API key management, and secure headers (using secure.py or similar) :contentReference[oaicite:2]{index=2}.

4. **Database & Data Schema**  
   - Define a PostgreSQL schema: ideas table with fields (id, text, priority, timestamps, improved_text).  
   - Add indexes on timestamp and priority to optimize filters and pagination. Use Alembic for migrations.

5. **Voice‑to‑Text Integration**  
   - Integrate an ML service (e.g., Whisper or Google Speech‑to‑Text) to handle voice input conversion to text before storage.

6. **Priority & Date‑Based Filtering**  
   - Allow users to tag ideas with High, Medium, or Low priority.  
   - Support API filtering and UI controls for date ranges (today, 3 days, week, month, 3/6 months).

7. **AI‑Driven “Improve Idea” Feature**  
   - Each idea row includes an “Improve” button calling an AI service (e.g., GPT‑4).  
   - The service should return 2–3 enhanced versions or actionable tips to be stored and displayed.

8. **CI/CD Pipeline & Deployment**  
   - Automate build, test (unit, security), containerization (Docker), migrations, deployment (e.g., via GitHub Actions or GitLab CI), and health checks :contentReference[oaicite:3]{index=3}.  
   - Implement zero‑downtime deployments (blue/green, canary), feature flags, automated rollbacks, and environment parity across dev/staging/prod :contentReference[oaicite:4]{index=4}.

9. **Security & DevSecOps**  
   - Use RBAC, MFA for CI/CD pipelines, secrets vault (e.g., HashiCorp Vault, GitHub Secrets) with auto‑rotation :contentReference[oaicite:5]{index=5}.  
   - Integrate SAST (SonarQube), SCA (Safety/Snyk), DAST (OWASP ZAP/Burp), IaC scanning, and container scans :contentReference[oaicite:6]{index=6}.  
   - Monitor pipeline logs, enforce security gates on vulnerabilities, perform regular security audits, compliance checks, and post‑deployment pentesting :contentReference[oaicite:7]{index=7}.

10. **Monitoring, Logging & Observability**  
   - Include logging in FastAPI, PostgreSQL, and AI calls.  
   - Use monitoring and alerting (Prometheus, Grafana, ELK/Splunk, Datadog) to track app health, performance, errors, and security incidents.

---

**Output Format Constraints:**  
- Use headings and numbered or bulleted lists.  
- Keep each section to 3–5 sentences.  
- Provide implementation-level, action‑oriented details.  
