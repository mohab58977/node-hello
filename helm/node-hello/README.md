# Node Hello Helm Chart

This Helm chart deploys the Node.js Hello World application to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8.0+

## Installing the Chart

To install the chart with the release name `node-hello`:

```bash
helm install node-hello ./helm/node-hello
```

To install the chart in a specific namespace:

```bash
helm install node-hello ./helm/node-hello --namespace node-hello --create-namespace
```

## Uninstalling the Chart

To uninstall the chart:

```bash
helm uninstall node-hello
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter                   | Description                       | Default                         |
| --------------------------- | --------------------------------- | ------------------------------- |
| `replicaCount`              | Number of replicas                | `2`                             |
| `image.repository`          | Image repository                  | `ghcr.io/mohab58977/node-hello` |
| `image.tag`                 | Image tag                         | `1.0.0`                         |
| `image.pullPolicy`          | Image pull policy                 | `IfNotPresent`                  |
| `service.type`              | Service type                      | `ClusterIP`                     |
| `service.port`              | Service port                      | `80`                            |
| `service.targetPort`        | Container port                    | `3000`                          |
| `ingress.enabled`           | Enable ingress                    | `false`                         |
| `resources.limits.cpu`      | CPU limit                         | `500m`                          |
| `resources.limits.memory`   | Memory limit                      | `512Mi`                         |
| `resources.requests.cpu`    | CPU request                       | `250m`                          |
| `resources.requests.memory` | Memory request                    | `256Mi`                         |
| `autoscaling.enabled`       | Enable horizontal pod autoscaling | `false`                         |

## Examples

### Deploy with custom values

```bash
helm install node-hello ./helm/node-hello \
  --set replicaCount=3 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=node-hello.example.com
```

### Deploy with values file

Create a `custom-values.yaml` file:

```yaml
replicaCount: 3
ingress:
  enabled: true
  hosts:
    - host: node-hello.example.com
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
```

Then install:

```bash
helm install node-hello ./helm/node-hello -f custom-values.yaml
```

### Enable autoscaling

```bash
helm install node-hello ./helm/node-hello \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=10 \
  --set autoscaling.targetCPUUtilizationPercentage=70
```
