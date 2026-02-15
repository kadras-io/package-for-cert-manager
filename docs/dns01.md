# Configuring DNS01 Challenge

The DNS01 challenge is used by cert-manager to prove domain ownership by creating specific DNS records. This guide explains how to configure DNS01 challenges for Hetzner, DigitalOcean, or Cloudflare DNS providers.

## Configuring DNS01 Challenge for Hetzner

To use Hetzner as your DNS provider for DNS01 challenges, you need to create a Kubernetes Secret containing your Hetzner API Token and then configure the cert-manager package to use that secret.

### Pre-requisites

In order to use the Hetzner DNS01 solver, you need to have the [cert-manager-webhook-hetzner](https://github.com/kadras-io/package-for-cert-manager-webhook-hetzner) package installed in your cluster. This package provides the necessary webhook for cert-manager to interact with Hetzner's DNS API.

### Step 1: Create a Hetzner API Token

Generate a new [Hetzner API Token](https://cloud.digitalocean.com/account/api/tokens/new) and copy the token for later use. Make sure to grant the token the necessary permissions to manage DNS records for your domains (read & write). For more details, check out the [Hetzner documentatio on generating an API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/).

### Step 2: Create Kubernetes Secret

Create a Kubernetes Secret in the specified namespace (default: `kadras-system`) containing your Hetzner API Token:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: hetzner-dns
  namespace: kadras-system
stringData:
  api-token: "<your-hetzner-api-token>"
```

### Step 3: Configure cert-manager package

To use DNS01 challenges, you need to configure the challenge type (by default it is set to `http01`) in the cert-manager package configuration and specify the secret containing your Hetzner API Token:

```yaml
letsencrypt:
  include: true
  production: false # Set to true for production environment
  email: your-email@example.com # Email address for ACME registration and recovery contact
  challenge:
    type: dns01
    secret:
      name: hetzner-dns
      key: api-token
      namespace: kadras-system
    dns_provider: hetzner
```

## Configuring DNS01 Challenge for DigitalOcean

To use DigitalOcean as your DNS provider for DNS01 challenges, you need to create a Kubernetes Secret containing your DigitalOcean Access token and then configure the cert-manager package to use that secret.

### Step 1: Create a DigitalOcean Access Token

Generate a new [DigitalOcean Personal Access Token](https://cloud.digitalocean.com/account/api/tokens/new) and copy the token for later use. Make sure to grant the token the necessary permissions to manage DNS records for your domains. For more details, check out the [cert-manager documentation on DigitalOcean DNS01](https://cert-manager.io/docs/configuration/acme/dns01/digitalocean/).

### Step 2: Create Kubernetes Secret

Create a Kubernetes Secret in the specified namespace (default: `kadras-system`) containing your DigitalOcean Access Token:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: digitalocean-dns
  namespace: kadras-system
stringData:
  access-token: "<your-digitalocean-access-token>"
```

### Step 3: Configure cert-manager package

To use DNS01 challenges, you need to configure the challenge type (by default it is set to `http01`) in the cert-manager package configuration and specify the secret containing your DigitalOcean Access Token:

```yaml
letsencrypt:
  include: true
  production: false # Set to true for production environment
  email: your-email@example.com # Email address for ACME registration and recovery contact
  challenge:
    type: dns01
    secret:
      name: digitalocean-dns
      key: access-token
      namespace: kadras-system
    dns_provider: digital_ocean
```

## Configuring DNS01 Challenge for Cloudflare

To use Cloudflare as your DNS provider for DNS01 challenges, you need to create a Kubernetes Secret containing your Cloudflare API token and then configure the cert-manager package to use that secret.

### Step 1: Create a Cloudflare API Token

Generate a new [Cloudflare API Token](https://dash.cloudflare.com/profile/api-tokens) and copy the token for later use. Make sure to grant the token the necessary permissions to manage DNS records for your domains (you can use the "Edit zone DNS" template). For more details, check out the [cert-manager documentation on Cloudflare DNS01](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/).

### Step 2: Create Kubernetes Secret

Create a Kubernetes Secret in the specified namespace (default: `kadras-system`) containing your Cloudflare API Token:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-dns
  namespace: kadras-system
stringData:
  api-token: "<your-cloudflare-api-token>"
```

### Step 3: Configure cert-manager package

To use DNS01 challenges, you need to configure the challenge type (by default it is set to `http01`) in the cert-manager package configuration and specify the secret containing your Cloudflare API Token:

```yaml
letsencrypt:
  include: true
  production: false # Set to true for production environment
  email: your-email@example.com # Email address for ACME registration and recovery contact
  challenge:
    type: dns01
    secret:
      name: cloudflare-dns
      key: api-token
      namespace: kadras-system
    dns_provider: cloudflare
```

## Additional Configuration Options

You can also configure recursive nameservers and other DNS01-specific settings:

```yaml
controller:
  dns01:
    recursive_nameservers:
      - "1.1.1.1:53"
      - "8.8.8.8:53"
    recursive_nameservers_only: false
```

This configuration allows you to specify custom DNS servers for the DNS01 challenge validation process.
