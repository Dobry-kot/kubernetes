resource "vault_policy" "kubernetes-sign" {
  for_each  = "${local.issuers_content_map}"

  name      = "clusters/${var.cluster_name}/certificates/${split(":","${each.key}")[1]}"

  policy = templatefile("templates/vault-certificate-sign-role.tftpl", { 
    pki_path           = "${local.ssl.intermediate[split(":","${each.key}")[0]].path}",
    cluster_name       = "${var.cluster_name}",
    pki_path_root      = "${local.root_vault_path_pki}",
    base_vault_path_kv = "${local.base_vault_path_kv}",
    issuer_name        = split(":","${each.key}")[1]
    approle_name       = split(":","${each.key}")[1]
    }
)
}

resource "vault_approle_auth_backend_role" "kubernetes-sign" {
  for_each                = "${local.issuers_content_map}"
  backend                 = "${vault_auth_backend.approle.path}"
  role_name               = split(":","${each.key}")[1]
  token_ttl               = 300
  token_policies          = ["default", vault_policy.kubernetes-sign[each.key].name]
  secret_id_bound_cidrs   = local.access_cidr_vault
  token_bound_cidrs       = local.access_cidr_vault
}

resource "vault_approle_auth_backend_role_secret_id" "kubernetes-sign-id" {
  for_each  = "${local.issuers_content_map}"
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "${vault_approle_auth_backend_role.kubernetes-sign[each.key].role_name}"
  cidr_list = []
}

resource "vault_approle_auth_backend_login" "kubernetes-sign-login" {
  for_each  = "${local.issuers_content_map}"
  backend   = "${vault_auth_backend.approle.path}"
  role_id   = "${vault_approle_auth_backend_role.kubernetes-sign[each.key].role_id}"
  secret_id = "${vault_approle_auth_backend_role_secret_id.kubernetes-sign-id[each.key].secret_id}"
}
