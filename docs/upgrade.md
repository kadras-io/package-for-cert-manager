# Upgrading

Upgrade cert-manager one minor version at a time, and read the [upgrade notes](https://cert-manager.io/docs/releases/) of each version first.

```shell
kctrl package installed update -i cert-manager -v ${VERSION} -n kadras-system
```

## Back up before uninstalling

The cert-manager CRDs are part of the package. Deleting the PackageInstall deletes them, and with them all the Certificates, Issuers, and ClusterIssuers in the cluster. The Secrets with the certificates are kept.

Back up the Issuers, ClusterIssuers, and Certificates, and the Secrets they reference, as described in [backup and restore](https://cert-manager.io/docs/devops-tips/backup/). To keep the CRDs when the package is deleted, add this ytt overlay (see [configuration.md](configuration.md#ytt-overlays)):

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "CustomResourceDefinition"}), expects="1+"
---
metadata:
  #@overlay/match missing_ok=True
  annotations:
    #@overlay/match missing_ok=True
    kapp.k14s.io/delete-strategy: orphan
```
