resource "vault_mount" "root" {
  path                      = "pki-root"
  type                      = "pki"
  description               = "root infrastruction"
  default_lease_ttl_seconds = 321408000
  max_lease_ttl_seconds     = 321408000
}

resource "vault_mount" "intermediate" {
  for_each                  = local.ssl.intermediate
  path                      = "${each.value.path}"
  type                      = vault_mount.root.type
  description               = "intermediate"
  default_lease_ttl_seconds = 321408000
  max_lease_ttl_seconds     = 321408000
}
