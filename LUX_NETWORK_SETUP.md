# LUX Network 11-Node Setup Guide

## Overview
This guide describes the setup for an 11-node LUX network with:
- 5 primary validator nodes (initial bootstrap set)
- 6 additional validator nodes (joining the network)
- Load-balanced RPC access via `api.lux.network`
- Individual staking endpoints via `nodeX.lux.network`

## Network Architecture

### Port Mapping
| Node | RPC Port (Even) | Staking Port (Odd) | Purpose |
|------|-----------------|-------------------|----------|
| 1    | 9630           | 9631              | Bootstrap validator |
| 2    | 9632           | 9633              | Bootstrap validator |
| 3    | 9634           | 9635              | Bootstrap validator |
| 4    | 9636           | 9637              | Bootstrap validator |
| 5    | 9638           | 9639              | Bootstrap validator |
| 6    | 9640           | 9641              | Additional validator |
| 7    | 9642           | 9643              | Additional validator |
| 8    | 9644           | 9645              | Additional validator |
| 9    | 9646           | 9647              | Additional validator |
| 10   | 9648           | 9649              | Additional validator |
| 11   | 9650           | 9651              | Additional validator |

### Load Balancing
- **api.lux.network**: Load balances across nodes 1-5 (ports 9630, 9632, 9634, 9636, 9638)
- Uses least_conn algorithm for optimal distribution
- Full access to C-Chain, X-Chain, and P-Chain APIs

### Individual Node Access
- **node1.lux.network** through **node11.lux.network**: Direct staking port access
- Used for bootstrapping and validator operations


### 3. Deploy Nginx Configuration
```bash
cd /home/z/work/lux/nginx
sudo ./deploy-lux-nodes.sh
```

This script:
- Removes old avalanche upstream configuration
- Installs new LUX node pool upstream
- Links all node configurations to nginx
- Reloads nginx with new configuration

## Configuration Files

### Upstream Configuration
- `/home/z/work/lux/nginx/lux-nodes-upstream.conf` - Load balancer pool (nodes 1-5)
- `/home/z/work/lux/nginx/lux-all-upstreams.conf` - Complete upstream replacement

### Node Configurations
- `/home/z/work/lux/nginx/node1-11.lux.network.conf` - Individual node configs

### Main API Configuration
- `/home/z/work/lux/nginx/api.lux.network-new.conf` - Load-balanced API endpoint

## Monitoring

### Check Node Health
```bash
# Check all nodes
for i in {1..11}; do
    port=$((9630 + ($i - 1) * 2))
    echo -n "Node $i: "
    curl -s -X POST --data '{"jsonrpc":"2.0","id":1,"method":"health.health"}' \
        -H 'content-type:application/json;' http://localhost:$port/ext/health | \
        jq -r '.result.healthy'
done
```

### View Logs
```bash
# Node logs
tail -f /home/z/.luxd/node1/node.log
tail -f /home/z/.luxd/node2/node.log
# ... etc
```

### Check Validator Status
```bash
curl -X POST --data '{
    "jsonrpc": "2.0",
    "method": "platform.getCurrentValidators",
    "params": {},
    "id": 1
}' -H 'content-type:application/json;' http://localhost:9630/ext/P
```

## Network Parameters
- **Network ID**: 96369
- **Consensus**: snow-sample-size=5, snow-quorum-size=3
- **Staking**: Enabled with sybil protection
- **APIs**: admin, keystore enabled for all nodes

## Troubleshooting

### Node Won't Start
1. Check if port is already in use: `netstat -tulpn | grep PORT`
2. Check logs: `tail -f /home/z/.luxd/nodeX/node.log`
3. Verify staking certificates exist

### Nginx Issues
1. Test configuration: `sudo nginx -t`
2. Check error logs: `sudo tail -f /var/log/nginx/error.log`
3. Verify upstream connectivity: `curl http://localhost:9630/ext/health`

### Bootstrap Issues
1. Ensure nodes 1-5 are healthy before starting nodes 6-11
2. Check bootstrap IPs in node logs
3. Verify network connectivity between nodes

## Security Notes
- All nodes run locally (127.0.0.1)
- External access controlled via nginx reverse proxy
- Staking certificates valid for 100 years
- Admin APIs should be disabled in production
