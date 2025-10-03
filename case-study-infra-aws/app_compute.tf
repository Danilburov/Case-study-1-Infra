resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.app_instance_type
  subnet_id                   = aws_subnet.app_private["0"].id
  associate_public_ip_address = false
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.app_ec2_sg.id]
  user_data                   = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y nginx
    echo "Hello from App EC2 in ${var.app_vpc_cidr}" > /var/www/html/index.html
    systemctl enable --now nginx
  EOF
  tags                        = { Name = "app-private-ec2" }
}

resource "aws_lb" "app" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.app_public["0"].id, aws_subnet.app_public["1"].id]
  tags               = { Name = "app-alb" }
}

resource "aws_lb_target_group" "app" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

output "alb_dns_name" { value = aws_lb.app.dns_name }
output "app_ec2_private_ip" { value = aws_instance.app.private_ip }
