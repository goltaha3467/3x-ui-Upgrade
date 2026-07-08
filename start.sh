#!/bin/bash
set -e

echo "🚀 Starting X-UI + nginx reverse proxy..."

if [ -z "$PORT" ]; then
  echo "⚠️  Warning: \$PORT is not set by Railway, defaulting to 8080 for nginx"
  export PORT=8080
fi

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

echo "🔧 Building nginx.conf for external port: $PORT"
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️  Starting x-ui in background..."
cd /usr/local/x-ui
./x-ui &
X_UI_PID=$!

sleep 2

echo "▶️  Starting nginx in foreground on port $PORT..."
nginx -t
exec nginx -g "daemon off;"
