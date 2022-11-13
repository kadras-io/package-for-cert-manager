# Cert Manager

This project provides a [Carvel package](https://carvel.dev/kapp-controller/docs/latest/packaging) for [Cert Manager](https://cert-manager.io), a cloud-native solution to automatically provision and manage TLS certificates in Kubernetes.

## Components

* Cert Manager

## Prerequisites

* Install the [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI to manage Carvel packages in a convenient way.
* Ensure [kapp-controller](https://carvel.dev/kapp-controller) is deployed in your Kubernetes cluster. You can do that with Carvel
[`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml
```

## Installation

You can install the Cert Manager package directly or rely on the [Kadras package repository](https://github.com/arktonix/carvel-packages)
(recommended choice).

Follow the [instructions](https://github.com/arktonix/carvel-packages) to add the Kadras package repository to your Kubernetes cluster.

If you don't want to use the Kadras package repository, you can create the necessary `PackageMetadata` and
`Package` resources for the Cert Manager package directly.

```shell
kubectl create namespace carvel-packages
kapp deploy -a cert-manager-package -n carvel-packages -y \
    -f https://github.com/arktonix/package-for-cert-manager/releases/latest/download/metadata.yml \
    -f https://github.com/arktonix/package-for-cert-manager/releases/latest/download/package.yml
```

Either way, you can then install the Cert Manager package using [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl).

```shell
kctrl package install -i cert-manager \
    -p cert-manager.packages.kadras.io \
    -v 1.10.0-kadras.1 \
    -n carvel-packages
```

You can retrieve the list of available versions with the following command.

```shell
kctrl package available list -p cert-manager.packages.kadras.io
```

You can check the list of installed packages and their status as follows.

```shell
kctrl package installed list -n carvel-packages
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

Then, reference it from the `kctrl` command when installing or upgrading the package.

```shell
kctrl package install -i cert-manager \
    -p cert-manager.packages.kadras.io \
    -v 1.10.0-kadras.1 \
    -n carvel-packages \
    --values-file values.yml
```

## Documentation

For documentation specific to Cert Manager, check out [cert-manager.io](https://cert-manager.io).

## References

This package is based on the original Cert Manager package used in [Tanzu Community Edition](https://github.com/vmware-tanzu/community-edition) before its retirement.

## Supply Chain Security

This project is compliant with level 2 of the [SLSA Framework](https://slsa.dev).

<img src="https://slsa.dev/images/SLSA-Badge-full-level2.svg" alt="The SLSA Level 2 badge" width=200>
