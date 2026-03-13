FROM python:3.14-slim

WORKDIR /app

# Install system dependencies for psycopg2 and other packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv for fast package management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Use uv pip install with the system Python environment
# We point it directly at the pyproject.toml to read the dependencies
RUN uv pip install --system -r pyproject.toml

# Copy project files
COPY . .

# Ensure environment variables are loaded
ENV PYTHONUNBUFFERED=1

# Default command (can be overridden in compose)
CMD ["python", "main.py"]
