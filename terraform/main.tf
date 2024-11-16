
module "base_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace  = "wh"
  stage      = "prod"
  attributes = ["public"]
  delimiter  = "-"

  tags = {
    "managed_by" = "terraform",
  }
}

module "fw_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name    = "fw"
  context = module.base_label.context
}

resource "digitalocean_firewall" "main" {
  name = module.fw_label.id

  # Inbound Rules
  inbound_rule {
    protocol         = "udp"
    port_range       = "1-65535" # Corrected full port range for UDP
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.firewall.server_ip_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = [var.firewall.server_ip_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "53"
    source_addresses = [var.firewall.server_ip_cidr]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = [var.firewall.server_ip_cidr]
  }

  # Outbound Rules
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
    # No port_range needed for ICMP
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535" # Corrected full port range for TCP
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535" # Corrected full port range for UDP
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

