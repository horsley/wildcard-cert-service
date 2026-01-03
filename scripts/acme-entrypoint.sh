#!/bin/sh
# acme.sh 容器入口脚本
# 首次启动时自动申请证书，之后由 daemon 模式自动续期

# 检查必要的环境变量
if [ -z "$DOMAIN" ]; then
    echo "Error: DOMAIN environment variable is required"
    exit 1
fi

if [ -z "$CF_Token" ] || [ -z "$CF_Account_ID" ]; then
    echo "Error: CF_Token and CF_Account_ID are required for Cloudflare DNS"
    exit 1
fi

if [ -z "$ACME_EMAIL" ]; then
    echo "Error: ACME_EMAIL is required for Let's Encrypt registration"
    exit 1
fi

CERT_FILE="/acme.sh/*.$DOMAIN_ecc/fullchain.cer"

# 设置默认 CA 为 Let's Encrypt（仅首次）
if [ ! -f "/acme.sh/ca/acme-v02.api.letsencrypt.org/directory/ca.conf" ]; then
    echo "==> Setting default CA to Let's Encrypt..."
    acme.sh --set-default-ca --server letsencrypt
fi

# 检查证书文件是否已存在
if [ ! -f "/acme.sh/*.$DOMAIN_ecc/fullchain.cer" ]; then
    echo "==> No valid certificate found, issuing new certificate for *.$DOMAIN"
    
    # 注册账户
    echo "==> Registering account with Let's Encrypt..."
    acme.sh --register-account -m "$ACME_EMAIL" || true
    
    # 申请证书，使用 --reloadcmd 在申请成功和后续续期时都会执行
    echo "==> Issuing wildcard certificate..."
    if acme.sh --issue --dns dns_cf -d "*.$DOMAIN" \
        --reloadcmd "/scripts/update-cert-info.sh"; then
        echo "==> Certificate issued successfully!"
    else
        echo ""
        echo "=========================================="
        echo "==> Certificate issuance FAILED."
        echo "==> Please check Cloudflare API configuration:"
        echo "    - CF_Token has Zone > DNS > Edit permission"
        echo "    - CF_Account_ID is correct"
        echo "    - Domain zone exists in this account"
        echo "==> Daemon will still run for manual retry via:"
        echo "    docker exec acme.sh acme.sh --issue --dns dns_cf -d \"*.$DOMAIN\" --reloadcmd \"/scripts/update-cert-info.sh\" --force"
        echo "=========================================="
        echo ""
    fi
else
    echo "==> Certificate already exists"
    # 确保 info.json 存在
    /scripts/update-cert-info.sh || true
fi

echo "==> Starting acme.sh daemon for auto-renewal..."
# 使用 exec 运行 crond，这样容器不会在证书申请失败时重启
exec crond -f
