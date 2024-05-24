variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/27"
}
variable "name_prefix" {
  type    = string
  default = "dbichel-portfolio-project"
}

variable "ami" {
  type    = string
  default = "ami-0bb84b8ffd87024d8"
}
