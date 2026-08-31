FROM python:3.11-slim

# coinor-cbc: PuLP ships a bundled CBC, but the distro build is the one that
# behaves predictably on slim images and on arm64.
RUN apt-get update \
 && apt-get install -y --no-install-recommends coinor-cbc curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /srv

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

EXPOSE 8000
HEALTHCHECK --interval=10s --timeout=3s --retries=10 \
  CMD curl -fsS http://localhost:8000/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
