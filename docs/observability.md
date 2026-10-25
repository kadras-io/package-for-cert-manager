# Observability

## Logs

The log level and format apply to all the cert-manager components.

```yaml
observability:
  logging:
    level: info
    format: json
```

* `level` is one of `info`, `debug`, `trace`. They map to the verbosity levels 2, 4, and 6 used by cert-manager.
* `format` is one of `text` and `json`.

## Metrics

All the components expose metrics in the Prometheus format on port 9402 (`/metrics`). By default, their Pods are annotated for Prometheus scraping (`prometheus.io/scrape`, `prometheus.io/port`, `prometheus.io/path`). To remove the annotations:

```yaml
observability:
  metrics:
    enabled: false
```

If you use the Prometheus Operator, create a PodMonitor instead:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: cert-manager
  namespace: cert-manager
spec:
  selector:
    matchLabels:
      app.kubernetes.io/instance: cert-manager
  podMetricsEndpoints:
    - port: http-metrics
```

The most useful metrics are about the certificates, like `certmanager_certificate_expiration_timestamp_seconds` and `certmanager_certificate_ready_status`. See [Prometheus metrics](https://cert-manager.io/docs/devops-tips/prometheus-metrics/).

## Dashboards and alerts

The [cert-manager mixin](https://monitoring.mixins.dev/cert-manager/) provides a Grafana dashboard and alerts, like certificates about to expire or not ready.
