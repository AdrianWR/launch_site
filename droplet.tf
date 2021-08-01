data "digitalocean_droplet" "current" {
  name = "devops42"
}

resource "digitalocean_ssh_key" "default" {
  name       = "Digital Ocean Public Key"
  public_key = file(var.ssh_public_key)
}

# Create a Digital Ocean Droplet
resource "digitalocean_droplet" "blog" {
  image      = "ubuntu-20-04-x64"
  name       = "blog"
  region     = "nyc1"
  size       = "s-1vcpu-1gb"
  ssh_keys   = [digitalocean_ssh_key.default.fingerprint]
  monitoring = true
}

resource "digitalocean_firewall" "blog" {
  name        = "blog-firewall"
  droplet_ids = [digitalocean_droplet.blog.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

}

output "blog_ip_address" {
  value = digitalocean_droplet.blog.ipv4_address
}