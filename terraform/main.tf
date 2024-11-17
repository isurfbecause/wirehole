
module "base_label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a"

  namespace  = "wh"
  stage      = "prod"
  attributes = ["public"]
  delimiter  = "-"

  tags = {
    "managed_by" = "terraform",
  }
}

module "fw_label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a"

  name    = "fw"
  context = module.base_label.context
}

# Create a new Web Droplet in the nyc2 region
# checkov:skip=CKV_DIO_2:SSH key is managed via 1Password
resource "digitalocean_droplet" "main" {
  image  = var.vm.image
  name   = var.vm.name
  region = var.vm.region
  size   = var.vm.size
}

resource "digitalocean_firewall" "main" {
  name        = module.fw_label.id
  droplet_ids = [digitalocean_droplet.main.id]

  # Allow all for VPN clients to connect to wireguard server
  # checkov:skip=CKV_DIO_4 Allowing wide-open ingress for VPN on port 51820
  inbound_rule {
    protocol         = "udp"
    port_range       = "51820"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }


  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.firewall.server_ip_cidr]
  }

  # For DNS resolution (Pi-hole using TCP only)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "53"
    source_addresses = [var.firewall.server_ip_cidr]
  }

  inbound_rule {
    protocol   = "tcp"
    port_range = "443"

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
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

