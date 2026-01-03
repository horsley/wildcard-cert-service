#!/bin/sh
# 由 acme.sh --reloadcmd 调用，生成证书信息 JSON
# 用于前端显示证书有效期

CERT_DIR=$(ls -d /acme.sh/*_ecc 2>/dev/null | head -1)

if [ -z "$CERT_DIR" ]; then
    echo "Error: No certificate directory found"
    exit 1
fi

CERT_FILE="$CERT_DIR/fullchain.cer"

if [ ! -f "$CERT_FILE" ]; then
    echo "Error: Certificate file not found: $CERT_FILE"
    exit 1
fi

# 提取证书有效期
NOT_AFTER=$(openssl x509 -in "$CERT_FILE" -noout -enddate 2>/dev/null | cut -d= -f2)

# 提取域名（CN）
DOMAIN_CN=$(openssl x509 -in "$CERT_FILE" -noout -subject 2>/dev/null | sed -n 's/.*CN *= *\([^,]*\).*/\1/p')

# 生成 JSON
cat > "$CERT_DIR/info.json" << EOF
{"notAfter":"$NOT_AFTER","domain":"$DOMAIN_CN"}
EOF

echo "Certificate info updated: $CERT_DIR/info.json"
cat "$CERT_DIR/info.json"
