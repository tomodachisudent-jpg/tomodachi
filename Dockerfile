# =======================
# Backend (FastAPI) Stage
# =======================
FROM python:3.11-slim AS be

# 作業ディレクトリ
WORKDIR /app

# 依存関係コピー & インストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーション本体コピー
COPY apis ./apis

# =======================
# Frontend (Vue) Stage
# =======================
FROM node:20-bullseye AS fe

WORKDIR /ui

# Alpine対応のネイティブビルド環境（Tiptap用）
# RUN apk add --no-cache python3 make g++ libc6-compat

COPY ui/package*.json ./
COPY ui/ ./

# 依存関係インストール
RUN npm install --legacy-peer-deps


# ソースコードをコピー
# COPY . .

# Quasar CLI をグローバルインストール（必要なら）
RUN npm install -g @quasar/cli

# 開発サーバ起動
RUN quasar build


# =======================
# Final Stage (Python + Nginx)
# =======================
FROM python:3.11-slim AS final

WORKDIR /app
ENV NOTIFICATION_WORKER_ENABLED=true

# Backend
COPY --from=be /app /app

# Nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*
COPY nginx.conf /etc/nginx/nginx.conf

# Frontend (Vue build)
COPY --from=fe /ui/dist/spa/. /usr/share/nginx/html/

# RUN rm -f /usr/share/nginx/html/index.nginx-debian.html
RUN chown -R www-data:www-data /usr/share/nginx/html

# Python依存パッケージを再インストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt uvicorn

# FastAPI + Nginx 同時起動
CMD ["sh", "-c", "uvicorn apis.main:app --host 0.0.0.0 --port 8000 & nginx -g 'daemon off;'"]
