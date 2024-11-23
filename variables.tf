variable "bkendrg" {
  type    = string
  default = "terraform_state"
}

variable "bkendcont" {
  type    = string
  default = "state"
}

variable "bkendstrge" {
  type    = string
  default = "terraformstate6627"
}



variable "location" {
  type    = string
  default = "West Us2"
}

variable "prefix" {
  type    = string
  default = "terracicd"
}

variable "tags" {
  type = map(string)
  default = {
    "Owner" = "Ofentse"
  }
}

variable "user" {
  type    = string
  default = "adm1npa57"
}

variable "pass" {
  type    = string
  default = "@adminpasswd1"

}