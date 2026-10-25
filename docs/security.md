# Security

cert-manager reads and writes Secrets across the cluster, so its workloads are hardened following the [cert-manager best practices](https://cert-manager.io/docs/installation/best-practice/).

## Pod Security Standards

The workloads comply with the `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), enforced on the package namespace: they run as non-root, with a read-only root filesystem, no privilege escalation, no capabilities, and the `RuntimeDefault` seccomp profile.

The Pods solving the ACME HTTP-01 challenges run in the namespaces of the Certificates, so they're not affected.

## Service account tokens

The service account tokens aren't auto-mounted. Each container mounts a projected token instead, which expires after an hour and is rotated by the kubelet.

## Network policies

The package can deny the inbound traffic to the cert-manager Pods, except for:

* the admission requests from the Kubernetes API server to the webhook, on port 10250;
* the metrics scraping, on port 9402.

```yaml
security:
  network_policies: true
```

The source of both isn't known in advance, so they're allowed from anywhere. The traffic from the kubelet, like health probes, is always allowed. The outbound traffic isn't restricted, since the controller reaches the Kubernetes API server, the ACME servers, and the DNS providers. Restrict them further with a ytt overlay (see [configuration.md](configuration.md#ytt-overlays)), for example to only allow scraping from the namespace of Prometheus:

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "NetworkPolicy", "metadata": {"name": "cert-manager-allow-metrics"}})
---
spec:
  ingress:
    #@overlay/match by=overlay.all
    -
      #@overlay/match missing_ok=True
      from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: observability
```

### Outbound traffic

The package doesn't restrict the outbound traffic, since its destinations depend on the cluster and the issuers:

* all the components reach the Kubernetes API server (usually on port 443 or 6443) and the cluster DNS (port 53);
* the controller also reaches the ACME servers and the DNS providers (port 443), the domains being validated for the HTTP-01 self-check (port 80), the RFC2136 nameserver, and the corporate proxy, if any.

To restrict it, create your own NetworkPolicies in the package namespace: they add up to the ones of the package. For example, to only allow the cainjector and the webhook to reach the cluster DNS and the Kubernetes API server, adjusting the API server ports to your cluster:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: cert-manager-cainjector-webhook-egress
  namespace: cert-manager
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/instance: cert-manager
    matchExpressions:
    - key: app.kubernetes.io/component
      operator: In
      values: [cainjector, webhook]
  policyTypes:
  - Egress
  egress:
  - ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 6443
```

The Pods solving the ACME HTTP-01 challenges are labelled `app.kubernetes.io/part-of: cert-manager-acme-solver`, so that your network policies in the namespaces of the Certificates can allow traffic to them.

## Kyverno policies

The package can include [Kyverno](https://github.com/kadras-io/package-for-kyverno) policies to verify the signatures of the cert-manager images, signed with the [cert-manager key](https://cert-manager.io/docs/installation/code-signing/). The package defines them as [ImageValidatingPolicies](https://kyverno.io/docs/policy-types/image-validating-policy/) in its namespace, so Kyverno 1.19 or later must be installed in the cluster.

```yaml
policies:
  enabled: true
```

Check the [policies](../package/config/policies) folder to know what policies are included.

## Access to cert-manager resources

Creating an Issuer in a namespace grants access to the Secrets in it, and anyone who can create Certificates can get them signed by the ClusterIssuers. Restrict who can create and edit cert-manager resources, as described in the [cert-manager threat model](https://cert-manager.io/docs/devops-tips/threat-modelling/).
