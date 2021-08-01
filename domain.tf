# Create a new domain
resource "digitalocean_domain" "blog" {
  name = "thelaunchsite.me"
}

# Create domain records
resource "digitalocean_record" "ipv4" {
  domain = digitalocean_domain.blog.name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.blog.ipv4_address
}

resource "digitalocean_record" "blog_address" {
  domain = digitalocean_domain.blog.name
  type   = "A"
  name   = "new"
  value  = digitalocean_droplet.blog.ipv4_address
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.blog.name
  type   = "CNAME"
  name   = "www"
  value  = "@"
}

output "blog_domain" {
  value = digitalocean_domain.blog.name
}