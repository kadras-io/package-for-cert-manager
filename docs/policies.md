# Policies

Validate and secure the package installation.

## Kyverno

This package provides an optional set of out-of-the-box policies to validate and secure the package installation and its functionality. The policies requires [Kyverno](https://kyverno.io) to be installed in your Kubernetes cluster.

```yaml
policies:
  include: true
```

Check the [policies](../package/config/policies) folder to know what policies are included.
