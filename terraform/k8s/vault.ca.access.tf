resource "vault_policy" "kubernetes-ca" {
  for_each  = toset(keys(local.ssl.intermediate))
  
  name      = "clusters/${var.cluster_name}/ca/${each.key}"

  policy = templatefile("templates/vault-intermediate-read-role.tftpl", { 
    pki_path           = "${local.ssl.intermediate["${each.key}"].path}",
    cluster_name       = "${var.cluster_name}",
    approle_name       = "${each.key}"
    }
  )
}

resource "vault_approle_auth_backend_role" "kubernetes-ca" {
  for_each  = toset(keys(local.ssl.intermediate))
  backend                 = vault_auth_backend.approle.path
  role_name               = "${each.key}"
  token_ttl               = 300
  token_policies          = ["default", vault_policy.kubernetes-ca[each.key].name]
  secret_id_bound_cidrs   = []
  token_bound_cidrs       = []
}

resource "vault_approle_auth_backend_role_secret_id" "kubernetes-ca-id" {
  for_each  = toset(keys(local.ssl.intermediate))
  backend   = vault_auth_backend.approle.path
  role_name = "${vault_approle_auth_backend_role.kubernetes-ca[each.key].role_name}"
  cidr_list = []
}

resource "vault_approle_auth_backend_login" "kubernetes-ca-login" {
  for_each  = toset(keys(local.ssl.intermediate))
  backend   = vault_auth_backend.approle.path
  role_id   = "${vault_approle_auth_backend_role.kubernetes-ca[each.key].role_id}"
  secret_id = "${vault_approle_auth_backend_role_secret_id.kubernetes-ca-id[each.key].secret_id}"
}
