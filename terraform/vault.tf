resource "vault_mount" "root" {
  path                      = "pki-root"
  type                      = "pki"
  description               = "root"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = 8640000
}

resource "vault_pki_secret_backend_root_cert" "example" {
  backend              = vault_mount.root.path
  type                 = "internal"
  common_name          = "Root CA"
  ttl                  = 86400
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  province             = "CA"
}

resource "vault_mount" "intermediate" {
  path                      = "${local.base_vault_path_pki}"
  type                      = vault_mount.root.type
  description               = "intermediate"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = 8640000
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.intermediate.path
  name             = "${var.cluster_name}-base-role"
  ttl              = 3600
  allow_ip_sans    = true
  allow_localhost  = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["${var.cluster_name}.example.com"]
  allow_subdomains = true
}

resource "vault_policy" "example" {
  name = "${var.cluster_name}"

  policy = local.vault_base_role
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "example" {
  backend        = vault_auth_backend.approle.path
  role_name      = "test-role"
#   token_max_ttl  = 60
  token_policies = ["default", vault_policy.example.name]
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.example.role_name
}

resource "vault_approle_auth_backend_login" "login" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.example.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.id.secret_id
}

output "instance_ip_addr" {
  value = "${vault_approle_auth_backend_login.login.client_token}"
}

output "policies" {
  value = "${vault_approle_auth_backend_role.example.token_policies}"
}

