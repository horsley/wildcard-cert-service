#!/bin/sh
# 生成前端配置文件
echo "window.CONFIG = { domain: '${DOMAIN}' };" > /usr/share/nginx/html/config.js

# 等待证书文件就绪
CERT_DIR="/certs/*.${DOMAIN}_ecc"
MAX_WAIT=300  # 最多等待 5 分钟
WAITED=0

echo "Waiting for certificate files..."
while [ ! -f "$CERT_DIR/fullchain.cer" ]; do
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo "Warning: Certificate not found after ${MAX_WAIT}s, starting anyway..."
        break
    fi
    sleep 5
    WAITED=$((WAITED + 5))
    echo "Waiting for certificate... (${WAITED}s)"
done

if [ -f "$CERT_DIR/fullchain.cer" ]; then
    echo "Certificate found!"
fi
