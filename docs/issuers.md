# Issuers

The package includes ClusterIssuers for a private CA and for Let's Encrypt. You can also create your own [Issuers and ClusterIssuers](https://cert-manager.io/docs/configuration/) next to them.

ClusterIssuers read their Secrets from the package namespace (`cert-manager` by default), which cert-manager calls the [cluster resource namespace](https://cert-manager.io/docs/configuration/#cluster-resource-namespace).

## Private CA

By default, the package creates a private CA and the `kadras-ca-issuer` ClusterIssuer, which signs certificates with it. Use it for internal traffic and for local development.

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: my-app
spec:
  secretName: my-app-tls
  dnsNames:
    - my-app.example.com
  issuerRef:
    name: kadras-ca-issuer
    kind: ClusterIssuer
```

The CA certificate is issued by the `kadras-bootstrap-issuer` self-signed ClusterIssuer and stored in the `kadras-root-ca` Secret in the package namespace. You can configure how long it's valid, and when it's renewed.

```yaml
issuers:
  private_ca:
    enabled: true
    duration: 8760h
    renew_before: 360h
```

When the CA certificate is renewed, the certificates it signed aren't re-issued: they keep their validity until their own renewal. Clients need to trust the CA, for example by distributing the `ca.crt` key of the `kadras-root-ca` Secret with [trust-manager](https://cert-manager.io/docs/trust/trust-manager/).

## Let's Encrypt

The package can include a ClusterIssuer for [Let's Encrypt](https://letsencrypt.org), named after the environment: `letsencrypt-staging-issuer` or `letsencrypt-prod-issuer`. Start with `staging`, since `production` enforces strict [rate limits](https://letsencrypt.org/docs/rate-limits/).

```yaml
issuers:
  letsencrypt:
    enabled: true
    environment: production
    email: security@example.com
```

The email is optional and only used as a contact for issues with the account.

Let's Encrypt verifies that you control the domains of a certificate via a [challenge](https://letsencrypt.org/docs/challenge-types/): HTTP-01 (default) or DNS-01.

### HTTP-01

cert-manager serves a token on port 80 of each domain, so the domains must point to your ingress controller and be reachable from the Internet. It doesn't support wildcard certificates.

By default, cert-manager routes the challenge requests via an Ingress with the `contour` IngressClass, which is served by the [Contour package](https://github.com/kadras-io/package-for-contour).

```yaml
issuers:
  letsencrypt:
    enabled: true
    http01:
      ingress_class: contour
```

When `gateway_api.enabled` is true, cert-manager attaches an HTTPRoute to the Gateway of the Contour package instead. See [gateway-api.md](gateway-api.md#http-01-challenges).

### DNS-01

cert-manager creates a TXT record in the DNS zone of each domain, so the domains don't need to be reachable from the Internet. It supports wildcard certificates.

The provider credentials are stored in a Secret. ClusterIssuers read their Secrets from the package namespace, so the package syncs the Secret there from `credentials.namespace` (default: `kadras-system`) using [secretgen-controller](https://github.com/kadras-io/package-for-secretgen-controller). If the Secret is already in the package namespace, it's used as is.

#### Hetzner

Requires the [cert-manager-webhook-hetzner](https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner) package. Create a [Hetzner API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/) with read and write permissions, and store it in a Secret.

```shell
kubectl create secret generic hetzner-dns -n kadras-system --from-literal=api-token=<token>
```

```yaml
issuers:
  letsencrypt:
    enabled: true
    solver: dns01
    dns01:
      provider: hetzner
      credentials:
        secret: hetzner-dns
        key: api-token
```

#### Cloudflare

Create a [Cloudflare API token](https://dash.cloudflare.com/profile/api-tokens) with the `Zone:DNS:Edit` and `Zone:Zone:Read` permissions, and store it in a Secret. See [Cloudflare](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/).

```shell
kubectl create secret generic cloudflare-dns -n kadras-system --from-literal=api-token=<token>
```

```yaml
issuers:
  letsencrypt:
    enabled: true
    solver: dns01
    dns01:
      provider: cloudflare
      credentials:
        secret: cloudflare-dns
        key: api-token
```

#### RFC2136

For authoritative DNS servers supporting dynamic updates authenticated with TSIG, like BIND, PowerDNS, and Knot. Store the TSIG secret in a Secret. See [RFC2136](https://cert-manager.io/docs/configuration/acme/dns01/rfc2136/).

```shell
kubectl create secret generic tsig -n kadras-system --from-literal=secret=<base64-tsig-secret>
```

```yaml
issuers:
  letsencrypt:
    enabled: true
    solver: dns01
    dns01:
      provider: rfc2136
      credentials:
        secret: tsig
        key: secret
      rfc2136:
        nameserver: ns1.example.com:53
        tsig_key_name: cert-manager
        tsig_algorithm: HMACSHA512
```

#### Webhook

Any other provider with a [cert-manager webhook](https://cert-manager.io/docs/configuration/acme/dns01/#webhook), like OVH, Scaleway, IONOS, or Gandi. Install the webhook, then set its API group, solver name, and configuration as documented by the webhook. The configuration is passed as is: it usually references a Secret in the package namespace.

```yaml
issuers:
  letsencrypt:
    enabled: true
    solver: dns01
    dns01:
      provider: webhook
      webhook:
        group_name: acme.mycompany.com
        solver_name: ovh
        config:
          endpoint: ovh-eu
          applicationKeyRef:
            name: ovh-credentials
            key: applicationKey
```

Set `credentials` too if you want the package to sync the Secret into the package namespace.

#### Propagation checks

Before asking Let's Encrypt to validate the challenge, cert-manager checks that the TXT record is visible on the authoritative DNS servers of the zone. When they can't be reached from the cluster, use recursive DNS servers instead.

```yaml
issuers:
  letsencrypt:
    dns01:
      recursive_nameservers:
        - 1.1.1.1:53
        - 9.9.9.9:53
      recursive_nameservers_only: true
```

## Default issuer

Ingresses annotated with `kubernetes.io/tls-acme: "true"` and no issuer annotation get their certificates from the default issuer: `kadras-ca-issuer`, unless you change it. See [Ingress](https://cert-manager.io/docs/usage/ingress/).

```yaml
issuers:
  default_issuer: letsencrypt-prod-issuer
```

When you disable the private CA, change the default issuer too, or set it to `""` to disable it.

```yaml
issuers:
  private_ca:
    enabled: false
  default_issuer: ""
```

## Certificate defaults

The package doesn't change the defaults of Certificates. To enforce defaults across the cluster, like the private key algorithm or the issuer, use a Kyverno mutation policy as described in [certificate defaults](https://cert-manager.io/docs/tutorials/certificate-defaults/).
