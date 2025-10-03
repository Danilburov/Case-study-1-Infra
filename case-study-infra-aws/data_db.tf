//automated creation of PostgreSQL

resource "aws_db_subnet_group" "data" {
  name       = "data-rds-subnets"
  subnet_ids = [aws_subnet.data_private["0"].id, aws_subnet.data_private["1"].id]
  tags       = { Name = "data-rds-subnets" }
}

resource "aws_db_instance" "postgres" {
  identifier             = "data-postgres"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.rds_instance_class
  username               = var.db_username
  password               = var.db_password
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.data.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true
  multi_az               = false
  skip_final_snapshot    = true
  apply_immediately      = true
  tags                   = { Name = "data-postgres" }
}

output "rds_endpoint" { value = aws_db_instance.postgres.address }
