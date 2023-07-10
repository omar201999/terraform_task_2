variable "subnet_tags" {
  description = "Tags for subnets"
  type        = map(string)
  default     = {
    "subnet1" = "Public"
    "subnet2" = "Private"
  }  
}

variable "public_sg_ingress_ports" {
  description = "Ingress ports for the public security group"
  type        = list(number)
  default     = [443,80, 22]
}

variable "private_sg_ingress_ports" {
  description = "Ingress ports for the private security group"
  type        = list(number)
  default     = [22]
}
variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}
 variable "route_cidr_block" {
description = "CIDR block for the route_table"
type        = string
   
 }

