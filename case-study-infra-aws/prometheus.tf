# Prometheus config file
locals {
  prometheus_yml = <<-YML
  global:
    scrape_interval: 15s
  scrape_configs:
    - job_name: "nodes"
      static_configs:
        - targets: ["localhost:9100"]   # monitor host
        # add your app EC2 later: "<app-private-ip>:9100"
  YML
}
