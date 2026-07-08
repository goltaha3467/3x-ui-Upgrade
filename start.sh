#!/bin/bash
set -e

echo "🚀 Starting X-UI + nginx reverse proxy..."

# nginx همیشه روی پورت ثابت 3000 گوش می‌دهد، فارغ از هر مقداری که Railway تزریق کند
# در Railway باید Target Port دقیقاً روی همین عدد (3000) تنظیم شود
export NGINX_PORT=3000

mkdir -p /etc/x-ui

# پنل همیشه روی پورت داخلی ثابت 2053 گوش می‌دهد (نه روی $PORT)
# این پورت هرگز مستقیماً از بیرون در دسترس نیست، فقط از طریق nginx
cat > /etc/x-ui/config.json << EOF
{
  "webPort": 2053,
  "webBasePath": "/managepanel/",
  "webListen": "0.0.0.0",
  "logLevel": "info"
}
EOF

echo "🔧 Building nginx.conf for fixed port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️  Starting x-ui in background..."
cd /usr/local/x-ui
./x-ui &
X_UI_PID=$!

sleep 2

echo "▶️  Starting nginx in foreground on port $NGINX_PORT..."
nginx -t
exec nginx -g "daemon off;"
