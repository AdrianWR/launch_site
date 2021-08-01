# Create a Digital Ocean Droplet
resource "digitalocean_droplet" "blog" {
  image      = "ubuntu-20-04-x64"
  name       = "blog"
  region     = "nyc1"
  size       = "s-1vcpu-1gb"
  monitoring = true
  ssh_keys = [
    data.digitalocean_ssh_key.default.id
  ]

  provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python -y"]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.ssh_private_key} playbook.yml"
  }
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

output "droplet_ip_address" {
  value = digitalocean_droplet.blog.ipv4_address
}