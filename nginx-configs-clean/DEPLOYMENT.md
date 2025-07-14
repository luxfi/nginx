# Blockscout Microservices Deployment Guide

This guide covers deploying Blockscout microservices with scalability and redundancy using Docker Swarm or Kubernetes.

## Current Architecture

The current setup runs individual Docker containers for each network:
- **LUX Network**: Backend (4000), Frontend (3000), Stats, Visualizer
- **ZOO Network**: Backend (4001), Frontend (3001), Stats, Visualizer  
- **SPC Network**: Backend (4002), Frontend (3002), Stats, Visualizer
- **Hanzo Network**: Backend (4003), Frontend (3003) - Prepared but not deployed

## Docker Swarm Deployment

### Prerequisites
1. Initialize Docker Swarm:
```bash
docker swarm init
```

2. Create overlay network:
```bash
docker network create --driver overlay --attachable blockchain-network
```

### Deploy with Docker Swarm

1. Set environment variables:
```bash
export LUX_DATABASE_URL="postgresql://blockscout:password@host:5432/explorer_luxnet?sslmode=disable"
export ZOO_DATABASE_URL="postgresql://blockscout:password@host:5432/explorer_zoonet?sslmode=disable"
export SPC_DATABASE_URL="postgresql://blockscout:password@host:5432/explorer_spcnet?sslmode=disable"
```

2. Deploy the stack:
```bash
docker stack deploy -c docker-compose-scalable.yml blockscout
```

3. Check service status:
```bash
docker service ls
docker service ps blockscout_luxnet-backend
```

### Scaling Services

Scale backend services:
```bash
docker service scale blockscout_luxnet-backend=5
docker service scale blockscout_zoonet-backend=3
```

## Kubernetes Deployment

### Prerequisites
1. Kubernetes cluster (local k3s, minikube, or cloud provider)
2. kubectl configured

### Deploy to Kubernetes

1. Create namespace and secrets:
```bash
kubectl create namespace blockscout

# Create secrets (base64 encode values first)
kubectl create secret generic luxnet-secrets \
  --from-literal=database-url="postgresql://..." \
  --from-literal=secret-key-base="..." \
  -n blockscout
```

2. Apply the deployment:
```bash
kubectl apply -f k8s-blockscout-deployment.yaml
```

3. Check deployment status:
```bash
kubectl get pods -n blockscout
kubectl get svc -n blockscout
kubectl get ingress -n blockscout
```

### Scaling in Kubernetes

The HorizontalPodAutoscaler automatically scales based on CPU/memory usage:
```bash
kubectl get hpa -n blockscout
```

Manual scaling:
```bash
kubectl scale deployment luxnet-backend --replicas=5 -n blockscout
```

## Load Balancing

### With Nginx (Current Setup)
- Individual nginx config files in `/home/z/nginx-configs-clean/`
- Each service has its own hostname configuration
- Enable configs by symlinking to `/etc/nginx/sites-enabled/`

### With Traefik (Docker Swarm)
- Traefik automatically discovers services via Docker labels
- Load balances between replicas
- Dashboard available at http://localhost:8080

### With Kubernetes Ingress
- Nginx Ingress Controller handles routing
- Automatic SSL with cert-manager (optional)
- Built-in load balancing across pods

## Monitoring

### Docker Swarm
```bash
# View service logs
docker service logs -f blockscout_luxnet-backend

# Monitor resource usage
docker stats
```

### Kubernetes
```bash
# View pod logs
kubectl logs -f deployment/luxnet-backend -n blockscout

# Monitor resources
kubectl top pods -n blockscout
kubectl top nodes
```

## Database Considerations

1. **Connection Pooling**: Each replica needs appropriate pool size
2. **Migrations**: Run only once, not from each replica
3. **Backup Strategy**: Regular backups of PostgreSQL databases

## Redis Configuration

Redis is used for:
- Caching blockchain data
- Session management
- Rate limiting

Single Redis instance is sufficient for most deployments. For HA, consider Redis Sentinel.

## Security Best Practices

1. **Secrets Management**:
   - Use Docker secrets or Kubernetes secrets
   - Never commit credentials to version control

2. **Network Security**:
   - Internal services should not be exposed directly
   - Use nginx/traefik for SSL termination

3. **Resource Limits**:
   - Set appropriate CPU/memory limits
   - Prevent resource exhaustion

## Troubleshooting

### Common Issues

1. **Database Connection Errors**:
   - Check DATABASE_URL format
   - Ensure PostgreSQL is accessible from containers
   - Verify credentials

2. **RPC Connection Issues**:
   - Verify Avalanche node is running
   - Check RPC endpoint URLs
   - Test with curl: `curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:9650/ext/bc/.../rpc`

3. **Frontend API Errors**:
   - Ensure NEXT_PUBLIC_API_HOST matches backend service
   - Check CORS configuration

### Logs and Debugging

```bash
# Docker
docker logs luxnet-backend
docker exec -it luxnet-backend sh

# Kubernetes
kubectl logs -f pod/luxnet-backend-xxx -n blockscout
kubectl exec -it pod/luxnet-backend-xxx -n blockscout -- sh
```

## Performance Tuning

1. **Backend Replicas**: 3-5 replicas per network recommended
2. **Frontend Replicas**: 2-3 replicas usually sufficient
3. **Database Connections**: POOL_SIZE=40 per replica
4. **Redis Memory**: Monitor usage, increase if needed

## Next Steps

1. Set up monitoring (Prometheus/Grafana)
2. Configure automated backups
3. Implement CI/CD pipeline
4. Add SSL certificates
5. Set up alerting for service health