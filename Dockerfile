FROM nginx:alpine

# 复制静态文件到镜像
COPY html/ /usr/share/nginx/html/

# 复制 nginx 模板
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# 复制 entrypoint 脚本
COPY scripts/entrypoint.sh /docker-entrypoint.d/99-config.sh
RUN chmod +x /docker-entrypoint.d/99-config.sh

EXPOSE 80
