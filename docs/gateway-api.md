# Gateway API

cert-manager issues certificates for the HTTPS listeners of [Gateways](https://gateway-api.sigs.k8s.io), and solves HTTP-01 challenges via HTTPRoutes. The Gateway API support is enabled by default, since the Kadras platform exposes applications via the Gateway API. To issue certificates for Ingresses instead, see [ingress.md](ingress.md).

The Gateway API CRDs must be installed before cert-manager starts, for example by the [Gateway API package](https://github.com/kadras-io/package-for-gateway-api): otherwise, the controller fails to start. If you install them later, restart the controller:

```shell
kubectl rollout restart deployment cert-manager -n cert-manager
```

To run cert-manager without the Gateway API CRDs, disable the support. The Let's Encrypt ClusterIssuer then requires the DNS-01 solver.

```yaml
gateway_api:
  enabled: false
```

## Certificates for Gateways

Annotate a Gateway with the issuer to use. cert-manager creates a Certificate for each listener with a `hostname`, `tls.mode: Terminate`, and a `certificateRefs` Secret in the same namespace. See [Gateway](https://cert-manager.io/docs/usage/gateway/).

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod-issuer
spec:
  gatewayClassName: envoy
  listeners:
    - name: https
      hostname: my-app.example.com
      port: 443
      protocol: HTTPS
      tls:
        mode: Terminate
        certificateRefs:
          - name: my-app-tls
```

## HTTP-01 challenges

The Let's Encrypt ClusterIssuer solves the HTTP-01 challenges by attaching an HTTPRoute to a Gateway listening for HTTP on port 80. By default, it's the `external` Gateway in the `envoy-gateway-system` namespace, deployed by the Envoy Gateway package, so no further configuration is needed.

```yaml
issuers:
  letsencrypt:
    enabled: true
```

To use another Gateway, set its name and namespace. The listener must allow routes from the namespaces of your Certificates.

```yaml
issuers:
  letsencrypt:
    http01:
      gateway:
        name: my-gateway
        namespace: my-namespace
```

## ListenerSets

[ListenerSet](https://cert-manager.io/docs/usage/gateway/#listenerset) support is alpha. Enable it via the controller configuration (see [configuration.md](configuration.md)):

```yaml
controller:
  config:
    gatewayAPI:
      enableListenerSet: true
    featureGates:
      ListenerSets: true
```
