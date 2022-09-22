
resource "tls_private_key" "kube_apiserver_sa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
} 

resource "vault_kv_secret_v2" "kube_apiserver_sa" {
  mount = "${vault_mount.kubernetes-secrets.path}"
  name                       = "kube-apiserver-sa"
  cas                        = 1
  delete_all_versions        = true
  data_json = jsonencode(
  {
    private = "${tls_private_key.kube_apiserver_sa_key.private_key_pem   }",
    public = "${tls_private_key.kube_apiserver_sa_key.public_key_pem  }"
  }
  )
}

resource "vault_policy" "kubernetes-kv" {
  name      = "clusters/${var.cluster_name}/kv/sa"

  policy = templatefile("templates/vault-kv-read.tftpl", { 
    cluster_name       = "${var.cluster_name}",
    approle_name       = "kube-apiserver-sa"
    }
  )
}

resource "vault_approle_auth_backend_role" "kubernetes-kv" {
  backend                 = "${vault_auth_backend.approle.path}"
  role_name               = "kube-apiserver-sa"
  token_ttl               = 300
  token_policies          = ["default", vault_policy.kubernetes-kv.name]
  secret_id_bound_cidrs   = []
  token_bound_cidrs       = []
}

resource "vault_approle_auth_backend_role_secret_id" "kubernetes-kv-id" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "${vault_approle_auth_backend_role.kubernetes-kv.role_name}"
  cidr_list = []
}

resource "vault_approle_auth_backend_login" "kubernetes-kv-login" {
  backend   = "${vault_auth_backend.approle.path}"
  role_id   = "${vault_approle_auth_backend_role.kubernetes-kv.role_id}"
  secret_id = "${vault_approle_auth_backend_role_secret_id.kubernetes-kv-id.secret_id}"
}
