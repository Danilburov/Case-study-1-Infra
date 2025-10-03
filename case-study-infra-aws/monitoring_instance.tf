//creating an EC2 instance on AWS that self-configures as a monitoring server
//it will run prometheus and grafana

resource "aws_instance" "monitor" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.hub_public[0].id
  vpc_security_group_ids      = [aws_security_group.mon_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  key_name                    = var.key_pair_name

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    # --- SSM agent for Ubuntu (via snap) ---
    snap install amazon-ssm-agent --classic || true
    systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true

    # --- Docker (apt path, simple & reliable) ---
    apt-get update -y
    apt-get install -y docker.io curl
    systemctl enable --now docker

    # --- Prometheus config ---
    mkdir -p /opt/mon
    cat > /opt/mon/prometheus.yml <<'PROME'
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: "prometheus"
        static_configs:
          - targets: ["localhost:9090"]
    PROME

    # --- Create a shared docker network so grafana can reach prometheus by name ---
    docker network create monnet || true

    # --- Start Prometheus (persistent) ---
    docker rm -f prometheus 2>/dev/null || true
    docker run -d --name prometheus \
      --restart unless-stopped \
      --network monnet \
      -p 9090:9090 \
      -v /opt/mon/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
      prom/prometheus:latest

    # --- Start Grafana (persistent) ---
    mkdir -p /opt/mon/graf-data
    docker rm -f grafana 2>/dev/null || true
    docker run -d --name grafana \
      --restart unless-stopped \
      --network monnet \
      -p 3000:3000 \
      -e GF_SECURITY_ADMIN_USER=admin \
      -e GF_SECURITY_ADMIN_PASSWORD=admin \
      -v /opt/mon/graf-data:/var/lib/grafana \
      grafana/grafana:latest

    # (Grafana datasource can be added via UI: URL http://prometheus:9090)
  EOF

  tags = { Name = "hub-monitoring" }
}
