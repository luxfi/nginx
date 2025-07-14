#!/bin/bash

# Update all nginx configs to listen on port 8080
echo "Updating nginx configurations to listen on port 8080..."

for conf in /etc/nginx/sites-available/*.conf; do
    if [ -f "$conf" ]; then
        echo "Updating $conf..."
        sudo sed -i 's/listen 80;/listen 8080;/g' "$conf"
        sudo sed -i 's/listen 80 /listen 8080 /g' "$conf"
    fi
done

# Also check the nginx main config for any port 80 listeners
if grep -q "listen.*80" /etc/nginx/nginx.conf; then
    echo "Found port 80 listeners in main nginx.conf, please update manually"
fi

echo "Configuration files updated. Please reload nginx."