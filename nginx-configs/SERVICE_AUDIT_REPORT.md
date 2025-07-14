# Service Audit Report - Nginx/DNS/Cloudflare Configuration
Generated: 2025-07-04

## Summary of Issues Found

### 1. Nginx Configuration Issues
- **Fixed**: Added missing CORS headers to api.lux.network, api.zoo.network, api.sparklepony.club
- **Fixed**: Corrected port inconsistency in api.hanzo.network (was 80, now 8080)
- **Fixed**: Removed .conf extensions from file names
- **Issue**: graph-cors still has .conf extension in symlink

### 2. Blockchain ID Mismatches
The running blockchain IDs don't match the documentation:
- **ZOO**: Running as Chain ID 200008 (not 200200 as documented)
- **SPC**: Running as Chain ID 36943 (not 36911 as documented)
- **LUX**: Correct at 96369
- **Hanzo**: Not deployed yet (placeholder HANZO_BLOCKCHAIN_ID)

### 3. Service Status

#### Working Services ✓
- LUX Mainnet RPC (http://127.0.0.1:9650/ext/bc/dnmzhuf6poM6PUNQCe7MWWfBdTJEnddhHRNXz2x7H6qSmyBEJ/rpc)
- ZOO Mainnet RPC (http://127.0.0.1:9650/ext/bc/bXe2MhhAnXg6WGj6G8oDk55AKT1dMMsN72S8te7JdvzfZX1zM/rpc)
- SPC Mainnet RPC (http://127.0.0.1:9650/ext/bc/QFAFyn1hh59mh7kokA55dJq5ywskF5A1yn8dDpLhmKApS6FP1/rpc)
- LUX Graph Node API (port 8000)
- LUX Blockscout (backend on port 4000, frontend on port 3000)
- SPC Blockscout (backend on port 4002, frontend on port 3002)

#### Not Working Services ✗
- **ZOO Blockscout**: Not running (needs to be started)
- **Hanzo services**: Network not deployed yet
- **Stats services**: All restarting continuously (luxnet-stats, zoonet-stats, spcnet-stats, hanzonet-stats)
- **Smart Contract Verifier**: Connection refused
- **Testnet RPCs**: All returning 404 (likely not configured)

#### Partially Working ⚠️
- LUX Explorer: Service running but returning 404 on some pages
- Visualizer: Service running but returning 404
- Sig Provider: Service running but returning 404

### 4. DNS/Cloudflare Tunnel Requirements

Based on the nginx configurations, these domains need to be configured:

#### LUX Network
- api.lux.network → Port 8080 (RPC)
- explore.lux.network → Port 8080 (Explorer Frontend)
- api-explore.lux.network → Port 8080 (Explorer API)
- stats.lux.network → Port 8080
- viz.lux.network → Port 8080
- sig.lux.network → Port 8080
- sc-verifier.lux.network → Port 8080
- user-ops.lux.network → Port 8080
- graph.lux.network → Port 8080
- bridge.lux.network → Port 8080
- explorer.lux.network → Redirect to explore.lux.network

#### ZOO Network
- api.zoo.network → Port 8080 (RPC)
- api-explore.zoo.network → Port 8080 (Explorer API)
- stats.zoo.network → Port 8080

#### SPC Network (Sparkle Pony Club)
- api.sparklepony.club → Port 8080 (RPC)
- api-explore.sparklepony.club → Port 8080 (Explorer API)
- stats.sparklepony.club → Port 8080

#### Hanzo Network (Prepared for future)
- api.hanzo.network → Port 8080 (RPC)
- api-explore.hanzo.network → Port 8080 (Explorer API)
- stats.hanzo.network → Port 8080
- hanzo.network → Port 8080

### 5. Services Fixed During This Audit

1. **Fixed CORS headers** on api.lux.network, api.zoo.network, api.sparklepony.club
2. **Fixed API host configuration** for all explorers:
   - LUX: Changed from localhost:4000 to api-explore.lux.network
   - ZOO: Changed from localhost:4001 to api-explore.zoo.network
   - SPC: Changed from localhost:4002 to api-explore.sparklepony.club
3. **Fixed Chain IDs** in explorer configurations:
   - ZOO: Changed from 200200 to 200008
   - SPC: Changed from 36911 to 36943
4. **Started ZOO Blockscout**: Backend and frontend now running on ports 4001/3001
5. **Fixed SPC migrations**: Enabled database migrations for SPC backend

### 6. Remaining Action Items

1. **Fix Stats Services** - Check why they're restarting:
   ```bash
   docker logs luxnet-stats
   docker logs zoonet-stats
   docker logs spcnet-stats
   ```

2. **Update Documentation** with correct Chain IDs:
   - ZOO: 200008
   - SPC: 36943

3. **Configure Cloudflare Tunnels** for all the domains listed above

4. **Fix graph-cors symlink**:
   ```bash
   sudo rm /etc/nginx/sites-enabled/graph-cors
   sudo ln -s /home/z/nginx-configs/graph-cors /etc/nginx/sites-enabled/graph-cors
   ```

5. **Deploy Hanzo Network** when ready and update HANZO_BLOCKCHAIN_ID placeholder

6. **Monitor Services** to ensure they stabilize after the configuration changes

### 6. Port Mapping Summary

All services are configured to listen on port 8080 in nginx and proxy to:
- Avalanche RPC: Port 9650
- Blockscout backends: Ports 4000-4003
- Blockscout frontends: Ports 3000-3003
- Graph nodes: Ports 8000, 8200, 8300
- Sig providers: Ports 8051, 8261, 8361, 8451
- Other microservices: Various ports

### 7. ZOO Blockchain Data Status
- ZOO blockchain data exists in all nodes
- Data size: 153MB in node1
- Blockchain ID: bXe2MhhAnXg6WGj6G8oDk55AKT1dMMsN72S8te7JdvzfZX1zM
- Located at: /home/z/.avalanche-cli/runs/network_20241113_190424/node*/chainData/