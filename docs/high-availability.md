# Configuring High Availability

High availability for Cert Manager can be configured using different strategies for the controllers and the webhooks.

## High availability for the controllers

The Cert Manager controllers support high availability following an active/passive model based on the leader election strategy. Since only one instance performs work at any given time, one replica for each Pod is enough.

The leader election strategy is enabled by default and can be customized.

```yaml
leader_election:
  lease_duration: "60s"
  renew_deadline: "40s"
  retry_period: "10s"
```

## High availability for the webhooks

High availability for the Cert Manager webhook can be enabled by configuring at least 2 replicas. In that case, a `PodDisruptionBudget` is automatically created to prevent downtime during node unavailability.

```yaml
webhook:
  replicas: 2
```
