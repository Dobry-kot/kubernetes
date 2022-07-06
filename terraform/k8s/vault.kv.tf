resource "tls_private_key" "test" {
  algorithm = "RSA"
  rsa_bits  = 4096
} 

resource "vault_kv_secret_v2" "secret" {
  mount = "${vault_mount.example.path}"
  name                       = "sa-key"
  cas                        = 1
  delete_all_versions        = true
  data_json = jsonencode(
  {
    private = "${tls_private_key.test.private_key_pem   }",
    public = "${tls_private_key.test.public_key_pem  }"
  }
  )
}


