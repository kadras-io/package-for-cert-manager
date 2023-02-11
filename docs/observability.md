# Configuring Observability

Monitor and observe the operation of Cert Manager using metrics.

## Metrics

The Cert Manager controller produces Prometheus metrics by default. This package comes pre-configured with the necessary annotations to let Prometheus scrape metrics automatically from the Cert Manager controller.

For more information, check the Cert Manager documentation for [metrics](https://cert-manager.io/docs/usage/prometheus-metrics).

## Dashboards

If you use the Grafana observability stack, you can refer to this [dashboard](https://gitlab.com/uneeq-oss/cert-manager-mixin) as a foundation to build your own.
