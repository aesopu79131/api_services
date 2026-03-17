#!/bin/bash
sudo chown -R nginx:nginx /var/www/html
sudo chmod -R 755 /var/www/html
systemctl start nginx
if ! systemctl is-active --quiet nginx; then
  echo "Nginx failed to start"
  exit 1
fi