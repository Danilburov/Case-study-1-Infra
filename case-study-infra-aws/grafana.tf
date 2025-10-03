# Grafana datasource config only (also adds CloudWatch datasource via IAM role on the instance)
locals {
  grafana_ds = <<-YML
  apiVersion: 1
  datasources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus:9090
      isDefault: true
    - name: CloudWatch
      type: cloudwatch
      jsonData:
        authType: ec2_iam_role
        defaultRegion: ${var.region}
  YML
}
