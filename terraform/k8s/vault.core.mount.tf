
resource "vault_mount" "root_ca" {
  for_each                  = local.ssl.root_ca
  path                      = "${each.value.path}"
  type                      = "pki"
  description               = "intermediate"
  default_lease_ttl_seconds = 321408000
  max_lease_ttl_seconds     = 321408000
}

resource "vault_mount" "intermediate" {
  for_each                  = local.ssl.intermediate
  path                      = "${each.value.path}"
  type                      = "pki"
  description               = "intermediate"
  default_lease_ttl_seconds = 321408000
  max_lease_ttl_seconds     = 321408000
}

resource "vault_mount" "example" {
  path        = "${local.base_vault_path_kv}"
  type        = "kv-v2"
  description = "KV Version 2 for K8S CP secrets"
}