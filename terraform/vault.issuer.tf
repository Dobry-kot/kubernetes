resource "vault_pki_secret_backend_role" "kubernetes-role" {
    depends_on = [vault_mount.intermediate]
    
    for_each                            = "${local.ssl.intermediate["kubernetes"].issuers}"
    backend                             = "${local.ssl.intermediate["kubernetes"].path}"
    allow_any_name                      = "${local.ssl["global-args"]["issuer-args"].allow_any_name}"
    allow_bare_domains                  = "${local.ssl["global-args"]["issuer-args"].allow_bare_domains}"
    allow_glob_domains                  = "${local.ssl["global-args"]["issuer-args"].allow_glob_domains}"
    allow_ip_sans                       = "${each.value.allow_ip_sans}"
    allow_localhost                     = "${each.value.allow_localhost}"
    allow_subdomains                    = "${local.ssl["global-args"]["issuer-args"].allow_subdomains}"
    allowed_domains_template            = "${local.ssl["global-args"]["issuer-args"].allowed_domains_template}"
    basic_constraints_valid_for_non_ca  = "${local.ssl["global-args"]["issuer-args"].basic_constraints_valid_for_non_ca}"
    client_flag                         = "${each.value.client_flag}"
    code_signing_flag                   = "${local.ssl["global-args"]["issuer-args"].code_signing_flag}"
    email_protection_flag               = "${local.ssl["global-args"]["issuer-args"].email_protection_flag}"
    enforce_hostnames                   = "${local.ssl["global-args"]["issuer-args"].enforce_hostnames}"
    generate_lease                      = "${local.ssl["global-args"]["issuer-args"].generate_lease}"
    key_bits                            = "${local.ssl["global-args"]["issuer-args"].key_bits}"
    key_type                            = "${local.ssl["global-args"]["issuer-args"].key_type}"
    key_usage                           = "${each.value.key_usage}"
    name                                = "${each.key}"
    no_store                            = "${local.ssl["global-args"]["issuer-args"].no_store}"
    require_cn                          = "${local.ssl["global-args"]["issuer-args"].require_cn}"
    server_flag                         = "${each.value.server_flag}"
    ttl                                 = "${local.ssl["global-args"]["issuer-args"].ttl}"
    use_csr_common_name                 = "${local.ssl["global-args"]["issuer-args"].use_csr_common_name}"
    allowed_domains                     = "${each.value.allowed_domains}"
    organization                        = "${each.value.organization}"
    # allowed_other_sans                  = "${each.value.allowed_other_sans}"
}

resource "vault_pki_secret_backend_role" "kubernetes-etcd" {
    depends_on = [vault_mount.intermediate]
    
    for_each                            = "${local.ssl.intermediate["etcd"].issuers}"
    backend                             = "${local.ssl.intermediate["etcd"].path}"
    allow_any_name                      = "${local.ssl["global-args"]["issuer-args"].allow_any_name}"
    allow_bare_domains                  = "${local.ssl["global-args"]["issuer-args"].allow_bare_domains}"
    allow_glob_domains                  = "${local.ssl["global-args"]["issuer-args"].allow_glob_domains}"
    allow_ip_sans                       = "${each.value.allow_ip_sans}"
    allow_localhost                     = "${each.value.allow_localhost}"
    allow_subdomains                    = "${local.ssl["global-args"]["issuer-args"].allow_subdomains}"
    allowed_domains_template            = "${local.ssl["global-args"]["issuer-args"].allowed_domains_template}"
    basic_constraints_valid_for_non_ca  = "${local.ssl["global-args"]["issuer-args"].basic_constraints_valid_for_non_ca}"
    client_flag                         = "${each.value.client_flag}"
    code_signing_flag                   = "${local.ssl["global-args"]["issuer-args"].code_signing_flag}"
    email_protection_flag               = "${local.ssl["global-args"]["issuer-args"].email_protection_flag}"
    enforce_hostnames                   = "${local.ssl["global-args"]["issuer-args"].enforce_hostnames}"
    generate_lease                      = "${local.ssl["global-args"]["issuer-args"].generate_lease}"
    key_bits                            = "${local.ssl["global-args"]["issuer-args"].key_bits}"
    key_type                            = "${local.ssl["global-args"]["issuer-args"].key_type}"
    key_usage                           = "${each.value.key_usage}"
    name                                = "${each.key}"
    no_store                            = "${local.ssl["global-args"]["issuer-args"].no_store}"
    require_cn                          = "${local.ssl["global-args"]["issuer-args"].require_cn}"
    server_flag                         = "${each.value.server_flag}"
    ttl                                 = "${local.ssl["global-args"]["issuer-args"].ttl}"
    use_csr_common_name                 = "${local.ssl["global-args"]["issuer-args"].use_csr_common_name}"
    allowed_domains                     = "${each.value.allowed_domains}"
    organization                        = "${each.value.organization}"
    # allowed_other_sans                  = "${each.value.allowed_other_sans}"
}

resource "vault_pki_secret_backend_role" "kubernetes-front-proxy" {
    depends_on = [vault_mount.intermediate]
    
    for_each                            = "${local.ssl.intermediate["front-proxy"].issuers}"
    backend                             = "${local.ssl.intermediate["front-proxy"].path}"
    allow_any_name                      = "${local.ssl["global-args"]["issuer-args"].allow_any_name}"
    allow_bare_domains                  = "${local.ssl["global-args"]["issuer-args"].allow_bare_domains}"
    allow_glob_domains                  = "${local.ssl["global-args"]["issuer-args"].allow_glob_domains}"
    allow_ip_sans                       = "${each.value.allow_ip_sans}"
    allow_localhost                     = "${each.value.allow_localhost}"
    allow_subdomains                    = "${local.ssl["global-args"]["issuer-args"].allow_subdomains}"
    allowed_domains_template            = "${local.ssl["global-args"]["issuer-args"].allowed_domains_template}"
    basic_constraints_valid_for_non_ca  = "${local.ssl["global-args"]["issuer-args"].basic_constraints_valid_for_non_ca}"
    client_flag                         = "${each.value.client_flag}"
    code_signing_flag                   = "${local.ssl["global-args"]["issuer-args"].code_signing_flag}"
    email_protection_flag               = "${local.ssl["global-args"]["issuer-args"].email_protection_flag}"
    enforce_hostnames                   = "${local.ssl["global-args"]["issuer-args"].enforce_hostnames}"
    generate_lease                      = "${local.ssl["global-args"]["issuer-args"].generate_lease}"
    key_bits                            = "${local.ssl["global-args"]["issuer-args"].key_bits}"
    key_type                            = "${local.ssl["global-args"]["issuer-args"].key_type}"
    key_usage                           = "${each.value.key_usage}"
    name                                = "${each.key}"
    no_store                            = "${local.ssl["global-args"]["issuer-args"].no_store}"
    require_cn                          = "${local.ssl["global-args"]["issuer-args"].require_cn}"
    server_flag                         = "${each.value.server_flag}"
    ttl                                 = "${local.ssl["global-args"]["issuer-args"].ttl}"
    use_csr_common_name                 = "${local.ssl["global-args"]["issuer-args"].use_csr_common_name}"
    allowed_domains                     = "${each.value.allowed_domains}"
    organization                        = "${each.value.organization}"
    # allowed_other_sans                  = "${each.value.allowed_other_sans}"
}

output "policies2" {

    value = "${local.ssl.intermediate["kubernetes"].issuers}"
}



