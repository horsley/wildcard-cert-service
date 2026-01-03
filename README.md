# SSL Certificate Service

基于 sslip.io/nip.io 的自助式域名解析说明和 SSL 证书下载服务。

## 功能

- 🌐 **域名生成器**：将 IP 地址转换为可用的域名格式
- 📜 **证书下载**：一键下载 fullchain 证书和私钥
- 📋 **PEM 复制**：直接复制证书/私钥内容
- 🔄 **自动续期**：基于 acme.sh daemon 模式自动续期证书

## 快速开始

### 1. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env` 文件：

```bash
# 泛域名（不含 *.）
DOMAIN=devcloud.example.com

# Cloudflare API 配置
CF_Token=your_cloudflare_api_token

# 以下二选一（推荐使用 CF_Zone_ID）
CF_Account_ID=your_cloudflare_account_id
CF_Zone_ID=your_cloudflare_zone_id

# Let's Encrypt 注册邮箱
ACME_EMAIL=admin@example.com
```

### 2. 启动服务

```bash
docker-compose up -d
```

首次启动时会自动申请证书，无需额外操作。

### 3. 访问服务

打开浏览器访问 `http://localhost`

## 前置条件

- 域名已配置 NS 记录指向 sslip.io 服务（或自建 sslip.io 服务）
- Cloudflare 账户并创建 API Token（需要 Zone > DNS > Edit 权限）
- Docker & Docker Compose

## Cloudflare API Token 创建

1. 访问 [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. 点击 "Create Token"
3. 选择 "Edit zone DNS" 模板
4. 配置权限为特定 Zone
5. 复制生成的 Token

Zone ID 和 Account ID 可在 Zone 的 Overview 页面右侧找到。

## 目录结构

```
.
├── docker-compose.yml
├── nginx.conf.template
├── .env.example
├── html/
│   ├── index.html
│   └── style.css
├── scripts/
│   ├── acme-entrypoint.sh  # acme.sh 容器入口，首次自动申请证书
│   ├── entrypoint.sh       # nginx 容器入口，生成 config.js
│   └── update-cert-info.sh # 证书续期后更新 info.json
└── certs/                  # 证书存储目录（自动生成）
```

## 证书续期

acme.sh 以 daemon 模式运行，会自动检查并续期即将过期的证书（默认每天检查一次，证书有效期少于 30 天时自动续期）。

## License

MIT
