# Cert Manager

This project provides a [Carvel package](https://carvel.dev/kapp-controller/docs/latest/packaging) for [Cert Manager](https://cert-manager.io), a cloud-native solution to automatically provision and manage TLS certificates in Kubernetes.

## Prerequisites

* Kubernetes 1.24+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml
  ```

## Installation

First, add the [Kadras package repository](https://github.com/arktonix/kadras-packages) to your Kubernetes cluster.

  ```shell
  kubectl create namespace kadras-packages
  kctrl package repository add -r kadras-repo \
    --url ghcr.io/arktonix/kadras-packages \
    -n kadras-packages
  ```

Then, install the Cert Manager package.

  ```shell
  kctrl package install -i cert-manager \
    -p cert-manager.packages.kadras.io \
    -v 1.10.1+kadras.1 \
    -n kadras-packages
  ```

### Verification

You can verify the list of installed Carvel packages and their status.

  ```shell
  kctrl package installed list -n kadras-packages
  ```

### Version

You can get the list of Cert Manager versions available in the Kadras package repository.

  ```shell
  kctrl package available list -p cert-manager.packages.kadras.io -n kadras-packages
  ```

## Configuration

The Cert Manager package has the following configurable properties.

| Config | Default | Description |
|--------|---------|-------------|
| `namespace` | `cert-manager` | The namespace in which to deploy Cert Manager. |

You can define your configuration in a `values.yml` file.

  ```yaml
  namespace: cert-manager
  ```

Then, pass the file when installing the package.

  ```shell
  kctrl package install -i cert-manager \
    -p cert-manager.packages.kadras.io \
    -v 1.10.1+kadras.1 \
    -n kadras-packages \
    --values-file values.yml
  ```

## Upgrading

You can upgrade an existing package to a newer version using `kctrl`.

  ```shell
  kctrl package installed update -i cert-manager \
    -v <new-version> \
    -n kadras-packages
  ```

You can also update an existing package with a newer `values.yml` file.

  ```shell
  kctrl package installed update -i cert-manager \
    -n kadras-packages \
    --values-file values.yml
  ```

## Other

The recommended way of installing the Cert Manager package is via the [Kadras package repository](https://github.com/arktonix/kadras-packages). If you prefer not using the repository, you can install the package by creating the necessary Carvel `PackageMetadata` and `Package` resources directly using [`kapp`](https://carvel.dev/kapp/docs/latest/install) or `kubectl`.

  ```shell
  kubectl create namespace kadras-packages
  kapp deploy -a cert-manager-package -n kadras-packages -y \
    -f https://github.com/arktonix/package-for-cert-manager/releases/latest/download/metadata.yml \
    -f https://github.com/arktonix/package-for-cert-manager/releases/latest/download/package.yml
  ```

## Support and Documentation

For support and documentation specific to Cert Manager, check out [cert-manager.io](https://cert-manager.io).

## References

This package is based on the original Cert Manager package used in [Tanzu Community Edition](https://github.com/vmware-tanzu/community-edition) before its retirement.

## Supply Chain Security

This project is compliant with level 2 of the [SLSA Framework](https://slsa.dev).

<img src="https://slsa.dev/images/SLSA-Badge-full-level2.svg" alt="The SLSA Level 2 badge" width=200>
