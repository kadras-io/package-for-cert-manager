load("@ytt:data", "data")
load("@ytt:struct", "struct")

# ###########
# COMPONENTS
# ###########

# The Deployment, container, and labels of each component, as defined in the upstream manifest.
def components():
  return [
    struct.encode({"key": "controller", "deployment": "cert-manager", "container": "cert-manager-controller", "app": "cert-manager", "name": "cert-manager", "component": "controller"}),
    struct.encode({"key": "cainjector", "deployment": "cert-manager-cainjector", "container": "cert-manager-cainjector", "app": "cainjector", "name": "cainjector", "component": "cainjector"}),
    struct.encode({"key": "webhook", "deployment": "cert-manager-webhook", "container": "cert-manager-webhook", "app": "webhook", "name": "webhook", "component": "webhook"}),
  ]
end

def component_labels(component):
  return {
    "app": component.app,
    "app.kubernetes.io/name": component.name,
    "app.kubernetes.io/instance": "cert-manager",
    "app.kubernetes.io/component": component.component,
  }
end

def component_selector(component):
  return {
    "app.kubernetes.io/name": component.name,
    "app.kubernetes.io/instance": "cert-manager",
    "app.kubernetes.io/component": component.component,
  }
end

def component_values(component):
  return getattr(data.values, component.key)
end

# The cert-manager components use the klog verbosity levels, where 2 is the default.
def log_verbosity():
  return {"info": 2, "debug": 4, "trace": 6}[data.values.observability.logging.level]
end

def logging_config():
  return {
    "verbosity": log_verbosity(),
    "format": data.values.observability.logging.format,
  }
end

# The upstream manifest passes the image of the HTTP-01 solver as a flag of the controller,
# which kbld can't resolve. The package moves it to the configuration file (see kbld-config.yml),
# reading it from the manifest so that it always matches the cert-manager version.
def acme_solver_image():
  manifest = data.read("/upstream/cert-manager.yaml")
  flag = "--acme-http01-solver-image="
  start = manifest.index(flag) + len(flag)
  return manifest[start:manifest.index("\n", start)].strip()
end

# The configurations computed from the package values. `<component>.config` is merged on top of them.

def controller_config():
  dns01 = data.values.issuers.letsencrypt.dns01
  config = {
    "apiVersion": "controller.config.cert-manager.io/v1alpha1",
    "kind": "ControllerConfiguration",
    "clusterResourceNamespace": data.values.namespace,
    "leaderElectionConfig": {
      "namespace": data.values.namespace,
    },
    "logging": logging_config(),
    "maxConcurrentChallenges": 60,
    "gatewayAPI": {
      "enabled": data.values.gateway_api.enabled,
    },
    "acmeHTTP01Config": {
      "solverImage": acme_solver_image(),
      #! Lets NetworkPolicies select the solver Pods, which run in the namespaces of the Certificates.
      "solverExtraLabels": {
        "app.kubernetes.io/part-of": "cert-manager-acme-solver",
      },
    },
    "acmeDNS01Config": {
      "recursiveNameservers": [ns for ns in dns01.recursive_nameservers if ns],
      "recursiveNameserversOnly": dns01.recursive_nameservers_only,
    },
  }

  if data.values.issuers.default_issuer:
    config["ingressShimConfig"] = {
      "defaultIssuerName": data.values.issuers.default_issuer,
      "defaultIssuerKind": "ClusterIssuer",
      "defaultIssuerGroup": "cert-manager.io",
    }
  end

  return config
end

def cainjector_config():
  return {
    "apiVersion": "cainjector.config.cert-manager.io/v1alpha1",
    "kind": "CAInjectorConfiguration",
    "leaderElectionConfig": {
      "namespace": data.values.namespace,
    },
    "logging": logging_config(),
  }
end

# The port of the webhook server, which can be changed via `webhook.config`.
def webhook_secure_port():
  return struct.decode(data.values.webhook.config).get("securePort", 10250)
end

def webhook_config():
  return {
    "apiVersion": "webhook.config.cert-manager.io/v1alpha1",
    "kind": "WebhookConfiguration",
    "securePort": webhook_secure_port(),
    "healthzPort": 6080,
    "logging": logging_config(),
  }
end

# ########
# ISSUERS
# ########

def letsencrypt_issuer_name():
  if data.values.issuers.letsencrypt.environment == "production":
    return "letsencrypt-prod-issuer"
  end
  return "letsencrypt-staging-issuer"
end

def letsencrypt_account_secret_name():
  if data.values.issuers.letsencrypt.environment == "production":
    return "letsencrypt-prod"
  end
  return "letsencrypt-staging"
end

def letsencrypt_server():
  if data.values.issuers.letsencrypt.environment == "production":
    return "https://acme-v02.api.letsencrypt.org/directory"
  end
  return "https://acme-staging-v02.api.letsencrypt.org/directory"
end

def http01_solver():
  http01 = data.values.issuers.letsencrypt.http01
  if data.values.gateway_api.enabled:
    return {
      "gatewayHTTPRoute": {
        "parentRefs": [{
          "group": "gateway.networking.k8s.io",
          "kind": "Gateway",
          "name": http01.gateway.name,
          "namespace": http01.gateway.namespace,
        }],
      },
    }
  end
  return {
    "ingress": {
      "ingressClassName": http01.ingress_class,
    },
  }
end

def dns01_solver():
  dns01 = data.values.issuers.letsencrypt.dns01
  secret_ref = {"name": dns01.credentials.secret, "key": dns01.credentials.key}

  if dns01.provider == "hetzner":
    #! Served by the Kadras cert-manager-webhook-hetzner package.
    return {
      "webhook": {
        "groupName": "acme.hetzner.kadras.io",
        "solverName": "hetzner",
        "config": {"tokenSecretKeyRef": secret_ref},
      },
    }
  elif dns01.provider == "cloudflare":
    return {"cloudflare": {"apiTokenSecretRef": secret_ref}}
  elif dns01.provider == "rfc2136":
    return {
      "rfc2136": {
        "nameserver": dns01.rfc2136.nameserver,
        "tsigKeyName": dns01.rfc2136.tsig_key_name,
        "tsigAlgorithm": dns01.rfc2136.tsig_algorithm,
        "tsigSecretSecretRef": secret_ref,
      },
    }
  end
  return {
    "webhook": {
      "groupName": dns01.webhook.group_name,
      "solverName": dns01.webhook.solver_name,
      "config": dns01.webhook.config,
    },
  }
end

def letsencrypt_solver():
  if data.values.issuers.letsencrypt.solver == "dns01":
    return {"dns01": dns01_solver()}
  end
  return {"http01": http01_solver()}
end

# Whether the DNS-01 credentials need syncing into the package namespace.
def sync_dns01_credentials():
  letsencrypt = data.values.issuers.letsencrypt
  credentials = letsencrypt.dns01.credentials
  return letsencrypt.enabled and letsencrypt.solver == "dns01" and credentials.secret != "" and credentials.namespace != data.values.namespace
end
