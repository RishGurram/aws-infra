variable "region" {
  type        = string
  description = "AWS region to use"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "profile" {
  type        = string
  description = "Profile to use for deployment"
}

variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "create_cidr" {
  type = bool
}

variable "public_subnet_cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr" {
  type    = list(any)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

locals {
  public_subnets  = var.create_cidr ? [for i in range(1, var.public_subnet_count + 1) : cidrsubnet(var.vpc_cidr_block, 8, i)] : var.public_subnet_cidr
  private_subnets = var.create_cidr ? [for i in range(1, var.private_subnet_count + 1) : cidrsubnet(var.vpc_cidr_block, 8, i + var.public_subnet_count)] : var.private_subnet_cidr
}

variable "instance_type" {
  type    = string
  default = "t2.micro"

}

variable "instance_volume_size" {
  type    = number
  default = 50
}

variable "app_port" {
  type    = number
  default = 8000
}

variable "ami" {
  type    = string
  default = "ami-044bf0a9d4d764dc7"
}

variable "instance_volume_type" {
  type    = string
  default = "gp2"
}
variable "S3Bucket" {
  default = "my-bucket"
}