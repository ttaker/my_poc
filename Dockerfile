# Multi-stage Dockerfile to keep the final image small.
# Builder stage: create a virtualenv and install Python dependencies there.

FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements.txt .

# Create a virtualenv and install requirements into it. This avoids
# leaving build-time caches or tools in the final image.
RUN python -m venv /opt/venv \
	&& /opt/venv/bin/pip install --upgrade pip setuptools wheel \
	&& /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim

# Put virtualenv binaries on PATH
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /app

# Copy the virtualenv from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy application sources
COPY . .

# Expose Streamlit default port
ENV PORT=8501
EXPOSE 8501

# Small healthcheck (optional): curl will be available in many base images; if not, the check will be skipped.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8501/ || exit 1

CMD ["streamlit", "run", "app.py", "--server.port", "8501", "--server.address", "0.0.0.0", "--server.enableCORS", "false"]
