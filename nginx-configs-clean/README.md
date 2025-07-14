# Individual Nginx Configuration Files

This directory contains individual nginx configuration files for each hostname, making them easy to manage and edit.

## LUX Network (Mainnet)
- `api.lux.network.conf` - RPC endpoint (port 9650)
- `explore.lux.network.conf` - Blockscout frontend (port 4000)
- `api-explore.lux.network.conf` - Blockscout API (port 4000/api)
- `stats.lux.network.conf` - Blockscout stats service (port 4004)
- `graph.lux.network.conf` - Graph Node service (port 8000)
- `ipfs.lux.network.conf` - IPFS service (port 5001)

## LUX Network (Testnet)
- `api-test.lux.network.conf` - Testnet RPC endpoint
- `explore-test.lux.network.conf` - Testnet explorer (port 3010)

## ZOO Network
- `api.zoo.network.conf` - RPC endpoint
- `explore.zoo.network.conf` - Blockscout frontend (port 4001)
- `api-explore.zoo.network.conf` - Blockscout API (port 4001/api)
- `graph.zoo.network.conf` - Graph Node service (port 8200)
- `ipfs.zoo.network.conf` - IPFS service (port 5002)

## SPC Network (SparklepPony.club)
- `api.sparklepony.club.conf` - RPC endpoint
- `explore.sparklepony.club.conf` - Blockscout frontend (port 4002)

## Hanzo Network (Prepared)
- `api.hanzo.network.conf` - RPC endpoint (blockchain ID TBD)
- `explore.hanzo.network.conf` - Blockscout frontend (port 4003)

## Installation
To enable these configurations:

```bash
# Copy all configs to sites-available
sudo cp /home/z/nginx-configs-clean/*.conf /etc/nginx/sites-available/

# Enable each site
cd /etc/nginx/sites-enabled/
for conf in /home/z/nginx-configs-clean/*.conf; do
    name=$(basename "$conf")
    sudo ln -sf ../sites-available/"$name" .
done

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

## Notes
- All configs use standard HTTP (port 80)
- RPC endpoints include CORS headers for cross-origin requests
- Blockscout services proxy to their respective Docker containers
- IPFS configs include increased upload limits (1G)