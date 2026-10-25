# cert-manager

![Test Workflow](https://github.com/kadras-io/package-for-cert-manager/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-cert-manager/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package for [cert-manager](https://cert-manager.io), a cloud-native solution to automatically provision and manage X.509 certificates in Kubernetes.

## ✨&nbsp; What's Included

* **Private CA**. The `kadras-ca-issuer` ClusterIssuer, signing certificates with a self-signed root CA managed by cert-manager.
* **Let's Encrypt**. An optional ClusterIssuer solving HTTP-01 challenges via Ingress or Gateway API, or DNS-01 challenges via Hetzner, Cloudflare, RFC2136, or any cert-manager webhook.
* **Gateway API**. Certificates for annotated Gateways, and HTTP-01 challenges solved via HTTPRoutes.
* **High availability**. Configurable replicas, protected by PodDisruptionBudgets and spread across nodes, running with the `system-cluster-critical` priority.
* **Observability**. Structured logs and Prometheus metrics.
* **Security**. The workloads comply with the `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), use short-lived service account tokens, and can be isolated with network policies. Optional Kyverno policies verify the signatures of the cert-manager images.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.35+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

### Dependencies

cert-manager has no required dependencies. Some features rely on other packages, which you can install from the [Kadras package repository](https://github.com/kadras-io/kadras-packages):

* [secretgen-controller](https://github.com/kadras-io/package-for-secretgen-controller), to sync the DNS-01 credentials into the cert-manager namespace and to authenticate with private registries.
* [cert-manager-webhook-hetzner](https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner), to solve DNS-01 challenges with Hetzner.
* [Kyverno](https://github.com/kadras-io/package-for-kyverno), to enforce the image verification policies.

### Installation

Add the Kadras [package repository](https://github.com/kadras-io/kadras-packages) to your Kubernetes cluster:

```shell
kctrl package repository add -r kadras-packages \
  --url ghcr.io/kadras-io/kadras-packages \
  -n kadras-system --create-namespace
```

<details><summary>Installation without package repository</summary>
The recommended way of installing the cert-manager package is via the Kadras <a href="https://github.com/kadras-io/kadras-packages">package repository</a>. If you prefer not using the repository, you can add the package definition directly using <a href="https://carvel.dev/kapp/docs/latest/install"><code>kapp</code></a> or <code>kubectl</code>.

```shell
kubectl create namespace kadras-system
kapp deploy -a cert-manager-package -n kadras-system -y \
  -f https://github.com/kadras-io/package-for-cert-manager/releases/latest/download/metadata.yml \
  -f https://github.com/kadras-io/package-for-cert-manager/releases/latest/download/package.yml
```
</details>

Install the cert-manager package:

```shell
kctrl package install -i cert-manager \
  -p cert-manager.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system
```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
> ```shell
> kctrl package available list -p cert-manager.packages.kadras.io -n kadras-system
> ```

Verify the installed packages and their status:

```shell
kctrl package installed list -n kadras-system
```

### Try It Out

Issue a certificate from the private CA:

```shell
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: hello
spec:
  secretName: hello-tls
  dnsNames:
    - hello.example.com
  issuerRef:
    name: kadras-ca-issuer
    kind: ClusterIssuer
EOF
```

Check that the certificate is ready. It's stored in the `hello-tls` Secret.

```shell
kubectl get certificate hello
```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to cert-manager, check out [cert-manager.io](https://cert-manager.io).

Features:

* [Issuers](docs/issuers.md)
* [Gateway API](docs/gateway-api.md)
* [High availability](docs/high-availability.md)
* [Observability](docs/observability.md)
* [Security](docs/security.md)

Operations:

* [Configuration and ytt overlays](docs/configuration.md)
* [Corporate proxy](docs/corporate-proxy.md)
* [Upgrading](docs/upgrade.md)
* [Verifying the release](docs/verify-release.md)

## 🎯&nbsp; Configuration

The cert-manager package can be customized via a `values.yml` file.

```yaml
issuers:
  letsencrypt:
    enabled: true
    environment: production
    email: security@example.com
observability:
  logging:
    format: json
```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

```shell
kctrl package install -i cert-manager \
  -p cert-manager.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

Anything not covered by the values can be customized via the configuration files of the cert-manager components or ytt overlays, as described in [docs/configuration.md](docs/configuration.md).

### Values

The cert-manager package has the following configurable properties.

<details><summary>Configurable properties</summary>

<!-- values-table:start -->

| Config | Default | Description |
|--------|---------|-------------|
| `namespace` | `"cert-manager"` | The namespace in which to deploy cert-manager. It's also where ClusterIssuers look for their Secrets and where leader election happens. |
| `controller.replicas` | `1` | The number of controller replicas. Additional replicas are hot standby via leader election: 2 are recommended for production. With more than 1 replica, a PodDisruptionBudget is created. |
| `controller.config` | `{}` | Controller configuration, merged on top of the one computed by the package. See https://cert-manager.io/docs/reference/api-docs/#controller.config.cert-manager.io/v1alpha1.ControllerConfiguration. |
| `cainjector.replicas` | `1` | The number of cainjector replicas. Additional replicas are hot standby via leader election: 2 are recommended for production. With more than 1 replica, a PodDisruptionBudget is created. |
| `cainjector.config` | `{}` | cainjector configuration, merged on top of the one computed by the package. See https://cert-manager.io/docs/reference/api-docs/#cainjector.config.cert-manager.io/v1alpha1.CAInjectorConfiguration. |
| `webhook.replicas` | `1` | The number of webhook replicas. All replicas serve requests: 3 are recommended for production. With more than 1 replica, a PodDisruptionBudget is created. |
| `webhook.config` | `{}` | Webhook configuration, merged on top of the one computed by the package. See https://cert-manager.io/docs/reference/api-docs/#webhook.config.cert-manager.io/v1alpha1.WebhookConfiguration. |
| `gateway_api.enabled` | `false` | Whether to issue certificates for annotated Gateways, and to solve the Let's Encrypt HTTP-01 challenges via `issuers.letsencrypt.http01.gateway` instead of an Ingress. The Gateway API CRDs must be installed before cert-manager starts. |
| `issuers.private_ca.enabled` | `true` | Whether to include the private CA and its ClusterIssuer. |
| `issuers.private_ca.duration` | `"8760h"` | How long the CA certificate is valid, in hours. |
| `issuers.private_ca.renew_before` | `"360h"` | How long before expiry the CA certificate is renewed, in hours. |
| `issuers.letsencrypt.enabled` | `false` | Whether to include a ClusterIssuer for Let's Encrypt. |
| `issuers.letsencrypt.environment` | `"staging"` | The Let's Encrypt environment. Use `staging` for testing, since `production` enforces strict rate limits. |
| `issuers.letsencrypt.email` | `""` | The email address registered with the Let's Encrypt account, used as a contact for account issues. Optional. |
| `issuers.letsencrypt.solver` | `"http01"` | The challenge type used to prove control of the domains. `dns01` is required for wildcard certificates. |
| `issuers.letsencrypt.http01.ingress_class` | `"contour"` | The IngressClass of the Ingress created to solve the challenge, when `gateway_api.enabled` is false. The default is the one of the Kadras Contour package. |
| `issuers.letsencrypt.http01.gateway.name` | `"contour"` | The name of the Gateway. |
| `issuers.letsencrypt.http01.gateway.namespace` | `"projectcontour"` | The namespace of the Gateway. |
| `issuers.letsencrypt.dns01.provider` | `"hetzner"` | The DNS provider. `hetzner` requires the Kadras cert-manager-webhook-hetzner package. `webhook` supports any provider with a cert-manager webhook. See https://cert-manager.io/docs/configuration/acme/dns01. |
| `issuers.letsencrypt.dns01.credentials.secret` | `""` | The name of the Secret. |
| `issuers.letsencrypt.dns01.credentials.key` | `""` | The key in the Secret holding the credentials. |
| `issuers.letsencrypt.dns01.credentials.namespace` | `"kadras-system"` | The namespace of the Secret. |
| `issuers.letsencrypt.dns01.rfc2136.nameserver` | `""` | The address of the authoritative DNS server, in the form `<host>:<port>`. |
| `issuers.letsencrypt.dns01.rfc2136.tsig_key_name` | `""` | The name of the TSIG key used to authenticate the updates. |
| `issuers.letsencrypt.dns01.rfc2136.tsig_algorithm` | `"HMACSHA512"` | The algorithm of the TSIG key. |
| `issuers.letsencrypt.dns01.webhook.group_name` | `""` | The API group of the webhook solver. |
| `issuers.letsencrypt.dns01.webhook.solver_name` | `""` | The name of the webhook solver. |
| `issuers.letsencrypt.dns01.webhook.config` | `{}` | The configuration for the webhook solver, specific to each provider. |
| `issuers.letsencrypt.dns01.recursive_nameservers` | `[]` | The recursive DNS servers used to check that the TXT records have propagated, as `<host>:<port>` or DNS-over-HTTPS URLs. If empty, the ones in the controller's `/etc/resolv.conf` are used. |
| `issuers.letsencrypt.dns01.recursive_nameservers_only` | `false` | Whether to only query `recursive_nameservers` to check the TXT records, instead of the authoritative servers of the zone. Useful when the authoritative servers aren't reachable, at the cost of slower checks due to caching. |
| `issuers.default_issuer` | `"kadras-ca-issuer"` | The ClusterIssuer used for Ingresses annotated with `kubernetes.io/tls-acme: "true"` and no issuer annotation. Set it to `""` to disable it. |
| `observability.logging.level` | `"info"` | The log level for all the components. |
| `observability.logging.format` | `"text"` | The log format for all the components. |
| `observability.metrics.enabled` | `true` | Whether to annotate the Pods for Prometheus scraping. All the components expose metrics on port 9402. |
| `security.network_policies` | `false` | Whether to deny the inbound traffic to the cert-manager Pods, except for the webhook requests from the Kubernetes API server and the metrics scraping. |
| `policies.enabled` | `false` | Whether to include Kyverno policies verifying the signatures of the cert-manager images. Kyverno must be installed in the cluster. |
| `proxy.http_proxy` | `""` | The proxy for HTTP traffic. |
| `proxy.https_proxy` | `""` | The proxy for HTTPS traffic. |
| `proxy.no_proxy` | `""` | A comma-separated list of hostnames, IP addresses, or IP ranges in CIDR format that should not use the proxy. |

<!-- values-table:end -->

</details>

## 🛠️&nbsp; Development

The development environment is defined with [devenv](https://devenv.sh). Enter it with `devenv shell`, or automatically with [direnv](https://direnv.net) after running `direnv allow`. Run `task --list` to see all the available tasks.

```shell
# Run the unit tests, which render the package and check the result without a cluster.
task test:config

# Create a local kind cluster and run the integration tests on it.
task cluster:setup
task test:integration

# Deploy the package from the local sources to the current cluster.
task dev

# Update the table of configurable values in this README after changing the values schema.
task docs:values
```

The unit tests are described in [test/unit/README.md](test/unit/README.md).

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
