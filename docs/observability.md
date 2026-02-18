# Configuring Observability

Monitor and observe the operation of cert-manager using metrics.

## Logs

The log verbosity for all cert-manager containers can be configured.

```yaml
controller:
  loglevel: 2
cainjector:
  loglevel: 2
webhook:
  loglevel: 2
```

## Metrics

The cert-manager controller produces Prometheus metrics by default. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from the cert-manager controller.

If you'd like to remove the Prometheus annotations and therefore disable automatic scraping of cert-manager metrics, you can apply the following configuration:

```yaml
prometheus:
  enabled: false
```

For more information, check the cert-manager documentation for [metrics](https://cert-manager.io/docs/devops-tips/prometheus-metrics/).

## Dashboards

If you use the Grafana observability stack, you can refer to this [dashboard](https://monitoring.mixins.dev/grafana/) as a foundation to build your own.
