# PoC Streamlit Docker image

This repository contains a minimal Streamlit app and a small, optimized Dockerfile.

Files
- `app.py` — minimal Streamlit app
- `requirements.txt` — Python dependencies
- `Dockerfile` — multi-stage build that installs dependencies into a virtualenv in a builder stage and copies only the virtualenv and app into the final image
- `.dockerignore` — excludes local virtualenv and other unnecessary files from the build context

Quick commands (zsh)

Build the optimized image:
```bash
cd /Users/vasylaleksenko/poc
docker build -t poc-streamlit:latest .
```

Run in the foreground (shows logs):
```bash
docker run --rm -p 8501:8501 poc-streamlit:latest
```

Run detached (background):
```bash
docker run -d --name poc-streamlit -p 8501:8501 poc-streamlit:latest
```

Stop a background container:
```bash
docker stop poc-streamlit
docker rm poc-streamlit
```

View logs:
```bash
docker logs -f poc-streamlit
```

Push to Docker Hub (example):
```bash
docker login
docker tag poc-streamlit:latest <your-dockerhub-username>/poc-streamlit:latest
docker push <your-dockerhub-username>/poc-streamlit:latest
```

Local development (mount source so edits show without rebuilding):
```bash
docker run --rm -p 8501:8501 -v "$PWD":/app -w /app poc-streamlit:latest
```

Notes on optimization
- Multi-stage build keeps the final image smaller by copying just the virtualenv and app sources.
- Using a virtualenv prevents installing build-time tools in the final image.
- Consider using a smaller base (e.g., `python:3.11-slim-bullseye` vs `slim`) or switching to `distroless`/`gcr.io/distroless` for more size savings, but that may require adding additional runtime binaries.
- If build time is a concern, enable Docker BuildKit and leverage build cache for pip wheels.

Healthcheck
- The `Dockerfile` adds a small HTTP healthcheck that will probe `http://localhost:8501/`. This helps orchestrators like Kubernetes detect readiness.

Want Kubernetes manifests or a CI workflow to automatically build and push this image? I can add those next.
 
CI / GitHub Actions
-------------------
This repo includes a GitHub Actions workflow at `.github/workflows/ci-build-and-push.yml` that:
- runs a build for pull requests targeting `main` (validation)
- builds and pushes the Docker image to GitHub Container Registry (GHCR) when commits are pushed to `main`

The workflow tags images as `ghcr.io/<org-or-username>/poc-streamlit:latest` and with the commit SHA.
The workflow uses the built-in `GITHUB_TOKEN` for authentication, so no extra secrets are required for pushing to GHCR under the same account/organization.

