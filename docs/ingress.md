# Ingress

The package is tailored to the [Gateway API](gateway-api.md), which the Kadras platform uses to expose applications. cert-manager still issues certificates for [Ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/), independently of `gateway_api.enabled`: you need an ingress controller, and, to solve HTTP-01 challenges, your own ClusterIssuer.

## Certificates for Ingresses

Annotate an Ingress with the issuer to use. cert-manager creates a Certificate for each entry in `spec.tls`, stored in the given Secret in the same namespace. See [Ingress](https://cert-manager.io/docs/usage/ingress/).

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    cert-manager.io/cluster-issuer: kadras-ca-issuer
spec:
  ingressClassName: nginx
  rules:
    - host: my-app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app
                port:
                  number: 80
  tls:
    - hosts:
        - my-app.example.com
      secretName: my-app-tls
```

The built-in ClusterIssuers that don't route challenges through a Gateway work with Ingresses as they are:

* `kadras-ca-issuer`, which signs certificates with the private CA;
* the Let's Encrypt ClusterIssuer with the DNS-01 solver (`issuers.letsencrypt.solver: dns01`), which creates TXT records instead of serving the challenges. See [issuers.md](issuers.md#dns-01).

## HTTP-01 challenges

The built-in Let's Encrypt ClusterIssuer solves HTTP-01 challenges via an HTTPRoute attached to a Gateway. To solve them via an Ingress, create your own ClusterIssuer with the `ingress` solver and the IngressClass of your ingress controller. See [HTTP01](https://cert-manager.io/docs/configuration/acme/http01/).

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-ingress-issuer
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: security@example.com
    privateKeySecretRef:
      name: letsencrypt-ingress
    solvers:
      - http01:
          ingress:
            ingressClassName: nginx
```

The ClusterIssuer reads the Secret with the ACME account key from the package namespace (`cert-manager` by default). Reference it from the `cert-manager.io/cluster-issuer` annotation of your Ingresses. The solver Pods run in the namespaces of the Certificates, labelled with `app.kubernetes.io/part-of: cert-manager-acme-solver`, so that your network policies there can allow the traffic from your ingress controller to them. See [security.md](security.md).

## Default issuer

cert-manager can issue certificates for the Ingresses annotated with `kubernetes.io/tls-acme: "true"` and no issuer annotation, from a default issuer. The package doesn't configure one, since it only applies to Ingresses. Set it via the controller configuration (see [configuration.md](configuration.md)):

```yaml
controller:
  config:
    ingressShimConfig:
      defaultIssuerName: letsencrypt-ingress-issuer
      defaultIssuerKind: ClusterIssuer
      defaultIssuerGroup: cert-manager.io
```
