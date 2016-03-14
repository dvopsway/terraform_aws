variable "access_key" {}

variable "secret_key" {}

variable "customer_name" {
    default = "hashicorp"
}

variable "region" {
    default = "ap-southeast-1"
}

variable "az_1" {
  default = {
      ap-southeast-1 = "ap-southeast-1a"
  }
}

variable "az_2" {
  default = {
      ap-southeast-1 = "ap-southeast-1b"
  }
}

variable "amis" {
  default = {
      ap-southeast-1 = "ami-0103cd62"
  }
}

variable "nat_ami" {
  default = {
      ap-southeast-1 = "ami-1a9dac48"
  }
}


variable "keyname" {
  default = {
      ap-southeast-1 = "hashicorp"
  }
}

variable "vpc_cidr" {
    default = "10.0.0.0/24"
}

variable "privatesubnet_cidr1" {
    default = "10.0.0.0/28"
}

variable "privatesubnet_cidr2" {
    default = "10.0.0.16/28"
}

variable "publicsubnet_cidr1" {
    default = "10.0.0.32/28"
}

variable "publicsubnet_cidr2" {
    default = "10.0.0.48/28"
}
