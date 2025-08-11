# Deployment Guide

This document provides instructions for deploying the Node.js Hello World application using different methods, including direct Helm deployment, Minikube setup, and ArgoCD configuration.

## Prerequisites

- **Kubernetes cluster** (local or cloud-based)
- **Helm 3.8.0+** installed
- **kubectl** configured to communicate with your cluster

## Deployment Methods

### 1. Direct Helm Deployment

This is the simplest method to deploy the application directly using Helm commands.

#### Install the Application

```bash
# Deploy to default namespace
helm install node-hello ./helm/node-hello

# Deploy to a specific namespace
helm install node-hello ./helm/node-hello --namespace node-hello --create-namespace
```

#### Customize the Deployment

You can customize the deployment by passing values directly:

```bash
helm install node-hello ./helm/node-hello \
  --set replicaCount=3 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=node-hello.local \
  --set resources.limits.memory=1Gi
```

Or create a custom values file:

```yaml
# custom-values.yaml
replicaCount: 3
ingress:
  enabled: true
  hosts:
    - host: node-hello.local
      paths:
        - path: /
          pathType: Prefix
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

Then deploy using the custom values:

```bash
helm install node-hello ./helm/node-hello -f custom-values.yaml
```

#### Upgrade the Application

```bash
# Upgrade with new values
helm upgrade node-hello ./helm/node-hello --set image.tag=latest

# Upgrade with custom values file
helm upgrade node-hello ./helm/node-hello -f custom-values.yaml
```

#### Uninstall the Application

```bash
helm uninstall node-hello
```

### 2. Minikube Setup

Minikube provides a local Kubernetes environment perfect for development and testing.

#### Prerequisites

- **Minikube** installed
- **Docker** or another container runtime

#### Start Minikube

```bash
# Start Minikube with sufficient resources
minikube start --memory=4096 --cpus=2

# Enable ingress addon if you want to use ingress
minikube addons enable ingress

# Enable metrics-server for HPA (if using autoscaling)
minikube addons enable metrics-server
```

#### Deploy the Application

```bash
# Deploy the application
helm install node-hello ./helm/node-hello

# If using ingress, update your values or use custom values
helm install node-hello ./helm/node-hello \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=node-hello.local
```

#### Access the Application

**Option 1: Port Forward (recommended for testing)**

```bash
kubectl port-forward service/node-hello 8080:80
# Access at http://localhost:8080
```

**Option 2: NodePort Service**

```bash
# Update service to NodePort
helm upgrade node-hello ./helm/node-hello --set service.type=NodePort

# Get the service URL
minikube service node-hello --url
```

**Option 3: Ingress (requires ingress addon)**

```bash
# Add to /etc/hosts
echo "$(minikube ip) node-hello.local" | sudo tee -a /etc/hosts

# Access at http://node-hello.local
```

#### Useful Minikube Commands

```bash
# View Minikube dashboard
minikube dashboard

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete

# SSH into Minikube
minikube ssh
```

### 3. ArgoCD Setup

ArgoCD enables GitOps-style deployments where your Git repository serves as the source of truth for your Kubernetes deployments.

#### Prerequisites

- Kubernetes cluster (can be Minikube)
- kubectl access to the cluster

#### Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

#### Access ArgoCD UI

**Option 1: Port Forward**

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Access at https://localhost:8080 (accept self-signed certificate)
```

**Option 2: NodePort (for Minikube)**

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
minikube service argocd-server -n argocd --url
```

#### Get ArgoCD Admin Password

```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Login with username: `admin` and the password from above.

#### Create ArgoCD Application

**Option 1: Via UI**

1. Login to ArgoCD UI
2. Click "New App"
3. Fill in the following details:
   - **Application Name**: `node-hello`
   - **Project**: `default`
   - **Sync Policy**: `Manual` or `Automatic`
   - **Repository URL**: Your Git repository URL (e.g., `https://github.com/mohab58977/node-hello`)
   - **Revision**: `HEAD` or specific branch
   - **Path**: `helm/node-hello`
   - **Destination Cluster**: `https://kubernetes.default.svc`
   - **Namespace**: `default` or `node-hello`
4. Click "Create"

**Option 2: Via YAML**

Create an ArgoCD Application manifest:

```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: node-hello
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/mohab58977/node-hello
    targetRevision: HEAD
    path: helm/node-hello
    helm:
      values: |
        replicaCount: 2
        ingress:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: node-hello
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

Apply the application:

```bash
kubectl apply -f argocd-application.yaml
```

#### GitOps Workflow

1. **Make Changes**: Update your Helm chart or values in the Git repository
2. **Commit and Push**: Push changes to the Git repository
3. **ArgoCD Sync**: ArgoCD will detect changes and sync automatically (if auto-sync is enabled) or manually trigger sync
4. **Deployment**: ArgoCD deploys the updated application to the cluster

#### Useful ArgoCD Commands

```bash
# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Login to ArgoCD CLI
argocd login localhost:8080

# List applications
argocd app list

# Get application details
argocd app get node-hello

# Sync application
argocd app sync node-hello

# Delete application
argocd app delete node-hello
```

## Monitoring and Troubleshooting

### Check Application Status

```bash
# Check pods
kubectl get pods

# Check services
kubectl get services

# Check ingress (if enabled)
kubectl get ingress

# Check application logs
kubectl logs -l app.kubernetes.io/name=node-hello

# Describe pod for troubleshooting
kubectl describe pod <pod-name>
```

### Health Checks

The application includes:

- **Liveness Probe**: Checks if the application is running (HTTP GET to `/` every 10 seconds after 30 seconds)
- **Readiness Probe**: Checks if the application is ready to serve traffic (HTTP GET to `/` every 5 seconds after 5 seconds)

### Scaling

```bash
# Manual scaling
kubectl scale deployment node-hello --replicas=5

# Enable HPA with Helm
helm upgrade node-hello ./helm/node-hello \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=10 \
  --set autoscaling.targetCPUUtilizationPercentage=70
```

## Configuration Parameters

Refer to the [Helm Chart README](helm/node-hello/README.md) for a complete list of configurable parameters and their default values.

## Best Practices

1. **Use specific image tags** in production instead of `latest`
2. **Set resource limits and requests** to ensure proper scheduling
3. **Enable health checks** to ensure application reliability
4. **Use ingress with TLS** for production deployments
5. **Monitor application metrics** and logs
6. **Test deployments** in a staging environment before production
7. **Use GitOps workflows** for better traceability and rollback capabilities
