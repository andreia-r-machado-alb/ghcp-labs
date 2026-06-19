# =============================================================================
# Reminder Engine — Multi-Stage Production Dockerfile
# =============================================================================
# Stage 1 (builder): installs Python dependencies in an isolated prefix.
# Stage 2 (production): copies only the installed packages and app source,
#   runs as a non-root user, and carries a built-in HEALTHCHECK.
# =============================================================================

# ─── Stage 1: Dependency builder ─────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build

# Copy only the requirements file first to leverage Docker layer caching.
# This layer is re-used on every rebuild unless requirements.txt changes.
COPY requirements.txt .

# Install into /install so we can copy the prefix cleanly to the runtime image.
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ─── Stage 2: Production runtime ─────────────────────────────────────────────
FROM python:3.12-slim AS production

# Create a dedicated non-root user/group (principle of least privilege).
RUN addgroup --system appgroup \
 && adduser  --system --ingroup appgroup --no-create-home appuser

WORKDIR /app

# Copy pre-built dependencies from the builder stage (no build tools included).
COPY --from=builder /install /usr/local

# Copy only the application source — nothing else ends up in the image.
COPY reminder_engine.py run_sprint_demo.py ./

# Give the non-root user ownership of the working directory.
RUN chown -R appuser:appgroup /app

# Switch to the non-root user for all subsequent commands.
USER appuser

# Document the port if an HTTP health endpoint is added in the future.
EXPOSE 8080

# Health check: verifies Python and the module are importable.
# start-period gives the container time to start before failures are counted.
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "import reminder_engine" || exit 1

# ENTRYPOINT + CMD pattern: makes the image behave like a Python executable
# while keeping the script overridable at runtime.
ENTRYPOINT ["python"]
CMD ["run_sprint_demo.py"]
