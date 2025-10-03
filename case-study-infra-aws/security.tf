# ALB external access (HTTP)
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.app.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.your_ip_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App EC2 accepts HTTP from ALB and SSH from your IP
resource "aws_security_group" "app_ec2_sg" {
  name   = "app-ec2-sg"
  vpc_id = aws_vpc.app.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    description = "SSH for admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS only accepts from App VPC CIDR (traffic arrives via TGW)
resource "aws_security_group" "rds_sg" {
  name   = "rds-postgres-sg"
  vpc_id = aws_vpc.data.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.app_vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "mon_sg" {
  name   = "monitoring-sg"
  vpc_id = aws_vpc.hub.id

  ingress { 
    from_port = 3000 
    to_port = 3000 
    protocol = "tcp" 
    cidr_blocks = [var.your_ip_cidr] 
    }
  ingress { 
    from_port = 9090 
    to_port = 9090 
    protocol = "tcp" 
    cidr_blocks = [var.your_ip_cidr] 
    }
  egress  { 
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
    }
}

