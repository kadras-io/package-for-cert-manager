# cert-manager

![Test Workflow](https://github.com/kadras-io/package-for-cert-manager/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-cert-manager/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Twitter](https://img.shields.io/static/v1?label=Twitter&message=Follow&color=1DA1F2)](https://twitter.com/kadrasIO)

A Carvel package for [cert-manager](https://cert-manager.io), a cloud-native solution to automatically provision and manage X.509 certificates in Kubernetes.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.28+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
  ```

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
>   ```shell
>   kctrl package available list -p cert-manager.packages.kadras.io -n kadras-system
>   ```

Verify the installed packages and their status:

  ```shell
  kctrl package installed list -n kadras-system
  ```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to cert-manager, check out [cert-manager.io](https://cert-manager.io).

## 🎯&nbsp; Configuration

The cert-manager package can be customized via a `values.yml` file.

  ```yaml
  namespace: cert-manager
  webhook:
    replicas: 2
  ```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

  ```shell
  kctrl package install -i cert-manager \
    -p cert-manager.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-system \
    --values-file values.yml
  ```

### Values

The cert-manager package has the following configurable properties.

<details><summary>Configurable properties</summary>

| Config | Default | Description |
|--------|---------|-------------|
| `namespace` | `cert-manager` | The namespace in which to deploy cert-manager. |
| `policies.include` | `false` | Whether to include the out-of-the-box Kyverno policies to validate and secure the package installation. |

Settings for the corporate proxy.

| Config | Default | Description |
|--------|---------|-------------|
| `proxy.http_proxy` | `""` | The HTTPS proxy to use for network traffic. |
| `proxy.https_proxy` | `""` | The HTTP proxy to use for network traffic. |
| `proxy.no_proxy` | `""` | A comma-separated list of hostnames, IP addresses, or IP ranges in CIDR format that should not use the proxy. |

Settings for the cert-manager controller.

| Config | Default | Description |
|--------|---------|-------------|
| `controller.loglevel` | `2` | Number of the log level verbosity. |

Settings for the cert-manager webhook.

| Config | Default | Description |
|--------|---------|-------------|
| `webhook.loglevel` | `2` | Number of the log level verbosity. |
| `webhook.replicas` | `1` | The number of replicas. In order to enable high availability, it should be greater than 1. |
| `webhook.host_network` | `false` | Whether to run the webhook in the host network so that it can be reached by the cert-manager controller in environments like AWS EKS. More information: https://cert-manager.io/docs/installation/compatibility/#aws-eks. |
| `webhook.secure_port` | `10250` | The port where the webhook is exposed. The default port needs changing in environments like AWS EKS and AWS Fargate. More information: https://cert-manager.io/docs/installation/compatibility/#aws-eks. |

Leader election configuration for the cert-manager and cert-manager-cainjector Deployments.

| Config | Default | Description |
|--------|---------|-------------|
| `leader_election.namespace` | `kube-system` | Namespace used to perform leader election. The default namespace needs changing in environments like GKE. More information: https://cert-manager.io/docs/installation/compatibility/#gke. |
| `leader_election.lease_duration` | `60s` | The duration that non-leader candidates will wait after observing a leadership renewal until attempting to acquire leadership of a led but unrenewed leader slot. This is effectively the maximum duration that a leader can be stopped before it is replaced by another candidate. |
| `leader_election.renew_deadline` | `40s` | The interval between attempts by the acting leader to renew a leadership slot before it stops leading. |
| `leader_election.retry_period` | `15s` | The duration the clients should wait between attempting acquisition and renewal of a leadership. |

</details>

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
