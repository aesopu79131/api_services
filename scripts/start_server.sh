#!/bin/bash
sudo chown -R nginx:nginx /var/www/html
sudo chmod -R 755 /var/www/html

# 重新產生 SSL（如果過期）
# certbot renew --quiet || true

systemctl start nginx
if ! systemctl is-active --quiet nginx; then
  echo "Nginx failed to start"
  exit 1
fi

yarn build
yarn start
