# Corporate Proxy

When running cert-manager behind a corporate proxy, configure the controller to reach the ACME servers and the DNS providers through it. The other components only talk to the Kubernetes API server.

```yaml
proxy:
  http_proxy: http://proxy.example.com:3128
  https_proxy: http://proxy.example.com:3128
  no_proxy: .svc,.cluster.local,10.0.0.0/8
```

Include in `no_proxy` the address of the Kubernetes API server and the Pod and Service networks, so that the cluster traffic doesn't go through the proxy.
