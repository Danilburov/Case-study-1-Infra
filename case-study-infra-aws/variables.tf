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