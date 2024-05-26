variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/27"
}

variable "availability_zone" {
  type = string
  default = "us-east-1a"
}

variable "name_prefix" {
  type    = string
  default = "dbichel-portfolio-project"
}

variable "ami" {
  type    = string
  default = "ami-0bb84b8ffd87024d8"
}

variable "workers" {
  type = number
  default = 2
}