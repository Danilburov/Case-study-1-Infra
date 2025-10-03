# Compose file that runs both services on the same EC2
locals {
  docker_compose = <<-YML
  version: "3.8"
  services:
    prometheus:
      image: prom/prometheus:latest
      volumes:
        - /opt/mon/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      ports: ["9090:9090"]

    node_exporter:
      image: prom/node-exporter:latest
      network_mode: "host"

    grafana:
      image: grafana/grafana:latest
      environment:
        - GF_SECURITY_ADMIN_USER=admin
        - GF_SECURITY_ADMIN_PASSWORD=admin
      volumes:
        - /opt/mon/grafana-ds.yml:/etc/grafana/provisioning/datasources/datasources.yml:ro
      ports: ["3000:3000"]
  YML
}
