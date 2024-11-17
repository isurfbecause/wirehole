variable "vm" {
  type = object({
    image  = string
    name   = string
    region = string
    size   = string
  })
}

variable "firewall" {
  description = "Configuration for the firewall resource"
  type = object({
    name           = string
    server_ip_cidr = string
  })
}
