variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-central-1"
}
#AZs keeps it simple and redundant enough
variable "azs" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}
# Non-overlapping CIDRs
variable "hub_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "app_vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}
variable "data_vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}
//Credentials / sizes
variable "key_pair_name" { type = string } # must exist in region
variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

//THESE MUST NOT BE LIKE THAT!
variable "db_username" {
  type    = string
  default = "postgresadmin"
}
variable "db_password" {
  type    = string
  default = "password"
}
variable "rds_instance_class" {
  type    = string
  default = "db.t4g.micro"
}
//For admin access to ALB/Grafana/SSH; tighten to your IP
variable "your_ip_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
//shared aws_ami for both app_compute and monitoring
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}