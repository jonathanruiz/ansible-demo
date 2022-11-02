variable "region" {
  default = "East US"
}

variable "vm-ipaddr" {
  default = ["10.0.1.51", "10.0.1.52", "10.0.1.53"]
}

variable "username" {
  type = string
  description = "The username for the VMs"
}

variable "password" {
  type = string
  description = "The password for the VMs"
  sensitive = true

}
