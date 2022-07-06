resource "vault_policy" "default" {
  name = "default-policy-${var.cluster_name}"
  policy = local.vault_base_role
}

resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "clusters/${var.cluster_name}/approle"
}

resource "vault_approle_auth_backend_role" "default" {
  backend             = vault_auth_backend.approle.path
  role_name           = "test-role"
  token_ttl           = 300
  token_policies      = ["default", vault_policy.default.name]
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.default.role_name
}

resource "vault_approle_auth_backend_login" "login" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.default.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.id.secret_id
}
