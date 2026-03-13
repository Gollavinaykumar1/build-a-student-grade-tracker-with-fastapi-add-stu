# Stage 1: Build the application
FROM python:3.10-slim as builder

# Set working directory to /app
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Stage 2: Create a non-root user and set up the application
FROM python:3.10-slim

# Set working directory to /app
WORKDIR /app

# Create a non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup -m appuser
RUN chown -R appuser:appgroup /app

# Copy application code from the builder stage
COPY --from=builder /app /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Expose port 8000
EXPOSE 8000

# Set the command to run when the container starts
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD curl --fail http://localhost:8000/health || exit 1

# Run as non-root user
USER appuser