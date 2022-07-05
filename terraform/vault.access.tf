# resource "vault_pki_secret_backend_role" "role" {
#   depends_on = [
#     vault_mount.intermediate
#   ]
#   for_each         = "${local.ssl.intermediate}"
#   backend          = "${each.value.path}"
#   name             = "base-role"
#   ttl              = 3600
#   allow_ip_sans    = true
#   allow_localhost  = true
#   key_type         = "rsa"
#   key_bits         = 4096
#   organization =  ["system:masters"]
#   allowed_domains = ["system:masters"]
#   allowed_domains_template= true
#   allow_bare_domains= true
#   enforce_hostnames = false
#   allow_subdomains = true
#   allow_any_name=true
#   key_usage        = ["DigitalSignature","KeyAgreement","KeyEncipherment","CertSign","CrlSign","ServerAuth","ClientAuth"]
# }

resource "vault_policy" "example" {
  name = "${var.cluster_name}"
  policy = local.vault_base_role
}

resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "clusters/cluster-1/approle"
}

resource "vault_approle_auth_backend_role" "example" {
  backend             = vault_auth_backend.approle.path
  role_name           = "test-role"
  token_ttl           = 300
  token_policies      = ["default", vault_policy.example.name]
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

# output "instance_ip_addr" {
#   value = "${vault_approle_auth_backend_login.login.client_token}"
# }

# output "policies" {
#   value = "${vault_approle_auth_backend_role.example.token_policies}"
# }


