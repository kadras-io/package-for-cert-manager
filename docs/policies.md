# Policies

Validate and secure the Cert Manager installation.

## Kyverno

This package provides an optional set of out-of-the-box policies to validate and secure the Cert Manager installation and functionality. The policies requires [Kyverno](https://kyverno.io) to be installed in your Kubernetes cluster.

The following configuration instructs the package to include the set of Kyverno policies.

```yaml
policies:
  include: true
```

Check the [policies](../package/config/policies) folder to know what policies are included.
