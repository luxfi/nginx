# Nginx Configuration Updates Summary

## Changes Made

1. **Created individual nginx configuration files** for each subdomain instead of one large file
2. **Fixed blockchain IDs** for all RPC endpoints:
   - LUX: `dnmzhuf6poM6PUNQCe7MWWfBdTJEnddhHRNXz2x7H6qSmyBEJ`
   - ZOO: `bXe2MhhAnXg6WGj6G8oDk55AKT1dMMsN72S8te7JdvzfZX1zM`
   - SPC: `QFAFyn1hh59mh7kokA55dJq5ywskF5A1yn8dDpLhmKApS6FP1`
   - Hanzo: `HANZO_BLOCKCHAIN_ID` (placeholder - network not deployed yet)

3. **Fixed CORS headers** for all services to allow proper cross-origin requests
4. **Ensured all RPC endpoints use port 9650**

## Files Created

### LUX Network
- `api.lux.network.conf` - Main RPC endpoint
- `explore.lux.network.conf` - Explorer frontend
- `api-explore.lux.network.conf` - Explorer API
- `stats.lux.network.conf` - Stats service
- `viz.lux.network.conf` - Visualizer
- `sig.lux.network.conf` - Signature provider
- `sc-verifier.lux.network.conf` - Smart contract verifier
- `user-ops.lux.network.conf` - User operations indexer

### ZOO Network
- `api.zoo.network.conf` - Main RPC endpoint
- `api-explore.zoo.network.conf` - Explorer API
- `stats.zoo.network.conf` - Stats service

### SPC Network
- `api.sparklepony.club.conf` - Main RPC endpoint
- `api-explore.sparklepony.club.conf` - Explorer API
- `stats.sparklepony.club.conf` - Stats service

### Hanzo Network (Prepared for future deployment)
- `api.hanzo.network.conf` - Main RPC endpoint (needs blockchain ID)
- `api-explore.hanzo.network.conf` - Explorer API
- `stats.hanzo.network.conf` - Stats service

## Deployment Instructions

1. Review the configuration files in `/home/z/nginx-configs/`
2. Run the deployment script:
   ```bash
   sudo /home/z/nginx-configs/deploy-nginx-configs.sh
   ```

This will:
- Backup existing configurations
- Copy all new config files to `/etc/nginx/sites-available/`
- Create symlinks in `/etc/nginx/sites-enabled/`
- Test the nginx configuration
- Reload nginx if tests pass

## Important Notes

- The Hanzo network blockchain ID needs to be updated once the network is deployed
- All services use port 8080 for listening
- CORS is configured to allow the respective explorer frontends
- The explorer API endpoints have open CORS (`*`) for broader access