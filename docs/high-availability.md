# High Availability

By default, the package runs 1 replica of each cert-manager component. For production, the [cert-manager best practices](https://cert-manager.io/docs/installation/best-practice/#high-availability) recommend 2 replicas of the controller and the cainjector, and 3 of the webhook.

```yaml
controller:
  replicas: 2
cainjector:
  replicas: 2
webhook:
  replicas: 3
```

* The **controller** and the **cainjector** follow an active/passive model: one replica is elected leader and does the work, the others are hot standby. More than 2 replicas bring little benefit.
* The **webhook** follows an active/active model: all replicas serve the admission requests from the Kubernetes API server. Since it validates every request for cert-manager resources, its availability matters the most.

Leader election happens in the package namespace.

## Disruptions

With more than one replica, a PodDisruptionBudget keeps at least one replica of the component available during voluntary disruptions, like node drains, and the replicas are spread across nodes on a best-effort basis. Single-node clusters keep working.

## Priority

All the components run with the `system-cluster-critical` [priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/), so that they're scheduled before, and evicted after, the workloads depending on their certificates. Some clusters only allow it in the `kube-system` namespace: in that case, create a ResourceQuota in the package namespace, as described in the [cert-manager best practices](https://cert-manager.io/docs/installation/best-practice/#scheduling).

## Resources

The package sets small resource requests and no limits. The memory used by the controller grows with the number and size of the certificates in the cluster. Tune them with a ytt overlay, as described in [configuration.md](configuration.md#resources).
