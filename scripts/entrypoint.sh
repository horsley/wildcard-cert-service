#!/bin/sh
# 生成前端配置文件
echo "window.CONFIG = { domain: '${DOMAIN}' };" > /usr/share/nginx/html/config.js
