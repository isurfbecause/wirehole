variable "firewall" {
  description = "Configuration for the firewall resource"
  type = object({
    name           = string
    server_ip_cidr = string
  })
}
