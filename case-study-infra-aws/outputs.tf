# EC2 instance ID
output "monitor_instance_id" {
  value = aws_instance.monitor.id
}

# Grafana URL (via public IP)
output "grafana_url" {
  value = "http://${aws_instance.monitor.public_ip}:3000"
}

# Prometheus URL (via public IP)
output "prometheus_url" {
  value = "http://${aws_instance.monitor.public_ip}:9090"
}
