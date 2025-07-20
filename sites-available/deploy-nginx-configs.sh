#!/bin/bash

# Deploy nginx configuration files by creating symlinks in sites-enabled

echo "Deploying nginx configurations..."

# Remove old symlinks that will be replaced
echo "Removing old configurations..."
sudo rm -f /etc/nginx/sites-enabled/api.lux.network
sudo rm -f /etc/nginx/sites-enabled/explore.lux.network
sudo rm -f /etc/nginx/sites-enabled/api-explore.lux.network
sudo rm -f /etc/nginx/sites-enabled/stats.lux.network
sudo rm -f /etc/nginx/sites-enabled/viz.lux.network
sudo rm -f /etc/nginx/sites-enabled/sig.lux.network
sudo rm -f /etc/nginx/sites-enabled/sc-verifier.lux.network
sudo rm -f /etc/nginx/sites-enabled/user-ops.lux.network
sudo rm -f /etc/nginx/sites-enabled/api.zoo.network
sudo rm -f /etc/nginx/sites-enabled/api-explore.zoo.network
sudo rm -f /etc/nginx/sites-enabled/stats.zoo.network
sudo rm -f /etc/nginx/sites-enabled/api.sparklepony.club
sudo rm -f /etc/nginx/sites-enabled/api-explore.sparklepony.club
sudo rm -f /etc/nginx/sites-enabled/stats.sparklepony.club
sudo rm -f /etc/nginx/sites-enabled/api.hanzo.network
sudo rm -f /etc/nginx/sites-enabled/api-explore.hanzo.network
sudo rm -f /etc/nginx/sites-enabled/stats.hanzo.network

# Create symlinks for all configuration files
echo "Creating symlinks..."
for conf in /home/z/nginx-configs/*; do
    filename=$(basename "$conf")
    # Skip non-config files
    if [[ "$filename" == *.conf || "$filename" == *.sh || "$filename" == *.md ]]; then
        continue
    fi
    
    echo "Linking $filename..."
    sudo ln -sf "$conf" "/etc/nginx/sites-enabled/$filename"
done

# Test nginx configuration
echo "Testing nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "Nginx configuration test passed!"
    echo "Reloading nginx..."
    sudo systemctl reload nginx
    echo "Nginx reloaded successfully!"
    
    # Show enabled sites
    echo -e "\nEnabled sites:"
    ls -la /etc/nginx/sites-enabled/
else
    echo "Nginx configuration test failed! Please check the configuration."
    exit 1
fi

echo "Deployment complete!"