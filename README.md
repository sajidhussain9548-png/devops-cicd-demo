# Automated CI/CD Pipeline for a Dockerized Web Application

Push code to GitHub -> robot tests it -> builds a Docker image -> scans it for
vulnerabilities -> pushes it to Docker Hub -> your laptop pulls and runs it,
with automatic rollback if the new version is unhealthy.

No cloud account is needed. AWS can be added later as a new deploy job.

## Architecture

```
 git push --> GitHub Actions
                 |-- 1. test         (npm test)
                 |-- 2. build image  (Dockerfile)
                 |-- 3. Trivy scan   (fails on CRITICAL vulnerabilities)
                 |-- 4. push image   (Docker Hub)
                 '-- 5. deploy       (self-hosted runner on your laptop -> scripts/deploy.sh)
                                       '-- health check -> rollback on failure
```

## Software to install on your laptop

| Tool | Why | Check |
|---|---|---|
| Git | version control | `git --version` |
| Node.js 20 LTS | run and test the app locally | `node -v` |
| Docker Desktop (Windows/Mac) or Docker Engine (Linux) | build and run containers | `docker --version` |
| Code editor (VS Code) | edit files | |
| curl | health checks | `curl --version` |
| Git Bash or WSL2 (Windows only) | runs `deploy.sh` | |

Accounts (free): GitHub and Docker Hub.

Laptop needs about 8 GB RAM (4 GB minimum), 10 GB free disk, and internet.

## Step 1: Run the app locally

```bash
npm install
npm test
npm start                      # http://localhost:3000
```

## Step 2: Run it in Docker locally

```bash
docker build -t devops-cicd-demo .
docker run -d -p 3000:3000 --name demo devops-cicd-demo
curl http://localhost:3000/health
docker rm -f demo
# or: docker compose up --build
```

## Step 3: Create the GitHub repo and push

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<your-username>/devops-cicd-demo.git
git push -u origin main
```

## Step 4: Add Docker Hub secrets

1. Docker Hub -> Account Settings -> Security -> New Access Token (Read & Write). Copy it.
2. GitHub repo -> Settings -> Secrets and variables -> Actions -> New repository secret:
   - `DOCKERHUB_USERNAME` = your Docker Hub username
   - `DOCKERHUB_TOKEN` = the token

Push again. The Actions tab should show test, build-scan-push turning green,
and the image appears on Docker Hub.

## Step 5: Enable auto-deploy to your laptop (self-hosted runner)

1. GitHub repo -> Settings -> Actions -> Runners -> New self-hosted runner.
2. Choose your OS and run the commands GitHub shows (download, `./config.sh`, `./run.sh`).
3. Keep the runner terminal open while deploying.
4. Settings -> Secrets and variables -> Actions -> Variables tab -> New variable:
   `ENABLE_DEPLOY` = `true`
5. Push a change. The app goes live at http://localhost:8080 (change port with the `PORT` env var).

Public repos only: never use a self-hosted runner on a public repo where strangers can open pull requests. Use a private repo, or turn the runner off when not testing.

## Demo script for the viva

1. Open http://localhost:8080 and show the version.
2. Change a line in `public/index.html`, commit, push.
3. Show the Actions tab running each stage.
4. Refresh the page: the new version appears.
5. Break a test on purpose and push: the pipeline stops and nothing is deployed.
6. Break `/health` on purpose: deploy fails and rolls back to the last version.

## Files

| File | Purpose |
|---|---|
| `src/`, `public/` | the web app |
| `tests/` | automated tests |
| `Dockerfile` | how to pack the app (non-root user, healthcheck) |
| `docker-compose.yml` | easy local run |
| `.github/workflows/ci-cd.yml` | the pipeline |
| `scripts/deploy.sh` | deploy + health check + rollback |

## Adding AWS later

Add a new job after `build-scan-push` that logs in to AWS (OIDC) and deploys the same image to EC2 or ECS. Nothing else changes.

## Ideas to extend

Slack/email notifications, staging environment, Prometheus + Grafana monitoring, Nginx reverse proxy with HTTPS.
