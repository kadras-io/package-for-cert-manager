# Configuring High Availability

High availability for cert-manager can be configured using different strategies for the controllers and the webhooks.

## High availability for controller and cainjector

The cert-manager controller and cainjector components support high availability following an active/passive model based on the leader election strategy. Only one instance performs work at any given time, but you can ensure redundancy by configuring 2 replicas for each component. In that case, a `PodDisruptionBudget` is automatically created for each component to prevent downtime during node unavailability.

The leader election strategy is enabled by default and can be customized.

```yaml
controller:
  replicas: 2
cainjector:
  replicas: 2
```

## High availability for the webhooks

High availability for the cert-manager webhook can be enabled by configuring at least 2 replicas. In that case, a `PodDisruptionBudget` is automatically created to prevent downtime during node unavailability.

```yaml
webhook:
  replicas: 3
```
