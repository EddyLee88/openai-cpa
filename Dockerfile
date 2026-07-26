FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    xdg-utils \
    libdbus-glib-1-2 \
    libxt6 \
    libxrender1 \
    libpci3 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

RUN set -e; \
    i=1; \
    while [ "$i" -le 3 ]; do \
      echo "[camoufox] fetch attempt $i/3"; \
      if python -m camoufox fetch; then \
        break; \
      fi; \
      if [ "$i" -eq 3 ]; then \
        echo "[camoufox] fetch failed after 3 attempts"; \
        exit 1; \
      fi; \
      i=$((i + 1)); \
      sleep 8; \
    done; \
    python -c "from pathlib import Path; from camoufox.pkgman import INSTALL_DIR, LAUNCH_FILE, OS_NAME; d=Path(str(INSTALL_DIR)); n=(LAUNCH_FILE.get(OS_NAME) if isinstance(LAUNCH_FILE, dict) else None); cs=([d/n] if n else []) + [d/'camoufox-bin', d/'camoufox.exe']; r=next((c for c in cs if c.is_file() and c.stat().st_size>0), None); assert r is not None, 'Camoufox browser binary missing after fetch dir=%s sample=%s' % (d, [p.name for p in (list(d.iterdir())[:20] if d.is_dir() else [])]); print('[camoufox] browser ready: %s' % r)"

COPY . .

RUN rm -rf utils/auth_core/*.py 2>/dev/null || true

EXPOSE 8000
ENV PYTHONUNBUFFERED=1 \
    GROK_LOCAL_SOLVER_BROWSER=camoufox

CMD ["python", "wfxl_openai_regst.py"]