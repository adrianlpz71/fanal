FROM python:3.13-slim AS base

COPY --from=ghcr.io/astral-sh/uv:0.9 /uv /usr/local/bin/uv

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_LINK_MODE=copy \
    PATH="/opt/venv/bin:$PATH" \
    TZ=Atlantic/Canary

WORKDIR /app

# Dependencias primero (capa cacheable). DEV=1 instala también pytest/ruff/mypy.
ARG DEV=0
COPY pyproject.toml uv.lock ./
RUN if [ "$DEV" = "1" ]; then uv sync --frozen; else uv sync --frozen --no-dev; fi

COPY . .

RUN useradd --system --uid 10001 faro && chown -R faro /app
USER faro

EXPOSE 8100
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8100", "--proxy-headers", "--forwarded-allow-ips", "*"]
