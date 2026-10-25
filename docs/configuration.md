# Configuration

The package values cover the decisions most installations need to make: issuers, high availability, observability, and security. Everything else can still be customized in two ways.

## Component configuration files

Each cert-manager component reads its [configuration file](https://cert-manager.io/docs/installation/configuring-components/) from a ConfigMap. The package computes it from the values, then merges `controller.config`, `cainjector.config`, and `webhook.config` on top, so their keys take precedence.

```yaml
controller:
  config:
    kubernetesAPIQPS: 50
    kubernetesAPIBurst: 100
    enableCertificateOwnerRef: true
    featureGates:
      ACMEUseARI: true
cainjector:
  config:
    enableInjectableConfig:
      apiServices: false
webhook:
  config:
    securePort: 10260
```

See the reference for the [controller](https://cert-manager.io/docs/reference/api-docs/#controller.config.cert-manager.io/v1alpha1.ControllerConfiguration), the [cainjector](https://cert-manager.io/docs/reference/api-docs/#cainjector.config.cert-manager.io/v1alpha1.CAInjectorConfiguration), and the [webhook](https://cert-manager.io/docs/reference/api-docs/#webhook.config.cert-manager.io/v1alpha1.WebhookConfiguration). A change rolls out the component.

## ytt overlays

Any Kubernetes resource of the package can be customized with a [ytt overlay](https://carvel.dev/ytt/docs/latest/ytt-overlays/), stored in a Secret and referenced from the PackageInstall via the `ext.packaging.carvel.dev/ytt-paths-from-secret-name.0` annotation.

```shell
kubectl create secret generic cert-manager-overlays -n kadras-system --from-file=overlays.yml
kubectl annotate packageinstall cert-manager -n kadras-system \
  ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=cert-manager-overlays
```

### Resources

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "cert-manager"}})
---
spec:
  template:
    spec:
      containers:
        #@overlay/match by="name"
        - name: cert-manager-controller
          #@overlay/match-child-defaults missing_ok=True
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              memory: 512Mi
```

### Node placement

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment"}), expects=3
---
spec:
  template:
    spec:
      #@overlay/match-child-defaults missing_ok=True
      nodeSelector:
        node-restriction.kubernetes.io/reserved-for: platform
      #@overlay/match missing_ok=True
      tolerations:
        - key: node-restriction.kubernetes.io/reserved-for
          operator: Equal
          value: platform
          effect: NoExecute
```

### Webhook on the host network

With some CNI plugins, the Kubernetes API server can't reach the Pod network, so the webhook must run on the host network. Since the kubelet already listens on port 10250, move the webhook to another port.

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "cert-manager-webhook"}})
---
spec:
  template:
    spec:
      #@overlay/match missing_ok=True
      hostNetwork: true
      #@overlay/match missing_ok=True
      dnsPolicy: ClusterFirstWithHostNet
```

```yaml
webhook:
  config:
    securePort: 10260
```

### DNS-01 providers

For DNS-01 providers not supported by the package values, like DigitalOcean or ACMEDNS, add a solver to the Let's Encrypt ClusterIssuer.

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "ClusterIssuer", "metadata": {"name": "letsencrypt-prod-issuer"}})
---
spec:
  acme:
    #@overlay/replace
    solvers:
      - dns01:
          digitalocean:
            tokenSecretRef:
              name: digitalocean-dns
              key: access-token
```
