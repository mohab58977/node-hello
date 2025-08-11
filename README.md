# Node Hello World

Simple Node.js application that serves "Hello World" - perfect for testing deployments, CI/CD pipelines, and Kubernetes configurations.

## Quick Start

### Local Development

```bash
# Install dependencies
npm install

# Start the application
npm start
```

The application will be available at `http://localhost:3000`.

### Code Quality

```bash
# Run linting
npm run lint

# Fix linting issues
npm run lint:fix

# Check code formatting
npm run format:check

# Format code
npm run format
```

## Documentation

- **[CI/CD Pipeline](CI-CD.md)** - Detailed documentation of the GitHub Actions CI/CD pipeline
- **[Deployment Guide](DEPLOY.md)** - Complete guide for deploying with Helm, Minikube, and ArgoCD
- **[Helm Chart](helm/node-hello/README.md)** - Helm chart configuration and usage

## Architecture

This application includes:

- **Node.js Express server** serving a simple "Hello World" response
- **Dockerfile** for containerization
- **Helm chart** for Kubernetes deployment
- **GitHub Actions CI/CD pipeline** for automated testing, building, and deployment
- **Security scanning** with Trivy
- **Code quality checks** with ESLint and Prettier

## Features

- ✅ **Automated CI/CD** with GitHub Actions
- ✅ **Container security scanning** with Trivy
- ✅ **Kubernetes-ready** with Helm charts
- ✅ **GitOps support** with ArgoCD integration
- ✅ **Health checks** (liveness and readiness probes)
- ✅ **Horizontal Pod Autoscaling** support
- ✅ **Ingress support** for external access
- ✅ **Resource management** with limits and requests
- ✅ **Security hardening** with non-root containers
