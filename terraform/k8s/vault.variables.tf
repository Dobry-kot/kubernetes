locals {
  base_vault_path_kv  = "clusters/${var.cluster_name}/kv"
  root_vault_path_pki = "pki-root"
  ssl = {
    global-args = {
      issuer-args = {
        allow_any_name                      = false
        allow_bare_domains                  = true
        allow_glob_domains                  = true
        allow_subdomains                    = false
        allowed_domains_template            = true
        basic_constraints_valid_for_non_ca  = false
        code_signing_flag                   = false
        email_protection_flag               = false
        enforce_hostnames                   = false
        generate_lease                      = false
        allow_ip_sans                       = false
        allow_localhost                     = false
        client_flag                         = false
        server_flag                         = false
        key_bits                            = 4096
        key_type                            = "rsa"
        key_usage                           = []
        organization                        = []
        country                             = []
        locality                            = []
        ou                                  = []
        postal_code                         = []
        province                            = []
        street_address                      = []
        allowed_domains                     = []
        allowed_other_sans                  = []
        allowed_serial_numbers              = []
        allowed_uri_sans                    = []
        ext_key_usage                       = []
        no_store                            = false
        require_cn                          = false
        ttl                                 = 31540000
        use_csr_common_name                 = true
        
      }
    }
    intermediate = {
      kubernetes = {
        common_name  = "Kubernetes Intermediate CA",
        description  = "Kubernetes Intermediate CA"
        path         = "clusters/${var.cluster_name}/pki/kubernetes"
        root_path    = "clusters/${var.cluster_name}/pki/root"
        type         = "internal"
        organization = "Kubernetes"
        issuers = {
          kube-controller-manager-client = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ClientAuth"]
              allowed_domains = [
                "system:kube-controller-manager"
              ]
              client_flag = true
            }
          },
          kube-apiserver-kubelet-client = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ClientAuth"]
              allowed_domains = [
                "custom:kube-apiserver-kubelet-client",
              ]
              organization = ["system:masters"]
              client_flag  = true
            }
          },
          kube-apiserver = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth"]
              allowed_domains = [
                "localhost",
                "kubernetes",
                "kubernetes.default",
                "kubernetes.default.svc",
                "kubernetes.default.svc.cluster",
                "kubernetes.default.svc.cluster.local",
                "custom:kube-apiserver",
                "api.${var.cluster_name}.${var.base_domain}"
              ]
              server_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
          },
          kube-controller-manager-server = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth"]
              allowed_domains = [
                "localhost",
                "kube-controller-manager.default",
                "kube-controller-manager.default.svc",
                "kube-controller-manager.default.svc.cluster",
                "kube-controller-manager.default.svc.cluster.local",
                "custom:kube-controller-manager"
              ]
              server_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
          },
          kube-scheduler-server = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth"]
              allowed_domains = [
                "localhost",
                "kube-scheduler.default",
                "kube-scheduler.default.svc",
                "kube-scheduler.default.svc.cluster",
                "kube-scheduler.default.svc.cluster.local",
                "custom:kube-scheduler"
              ]
              server_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
          },
          kube-scheduler-client = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ClientAuth"]
              allowed_domains = [
                "system:kube-scheduler"
              ]
              client_flag = true
            }
          },
          kubelet-server = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth"]
              allowed_domains = [
                "localhost",
                "*.${var.cluster_name}.${var.base_domain}",
                "system:node:*"
              ]
              organization = [
                "system:nodes",
              ]
              server_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
          }
          kubelet-client = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ClientAuth"]
              allowed_domains = [
                "system:node:*",
              ]
              organization = [
                "system:nodes",
              ]
              client_flag = true
            }
          },
        }
      }
      etcd = {
        common_name  = "ETCD Intermediate CA",
        description  = "ETCD Intermediate CA"
        path         = "clusters/${var.cluster_name}/pki/etcd"
        root_path    = "clusters/${var.cluster_name}/pki/root"
        type         = "internal"
        organization = "Kubernetes"
        issuers = {
          etcd-server = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/etcd"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth"]
              allowed_domains = [
                "system:etcd-server",
                "localhost",
                "*.${var.cluster_name}.${var.base_domain}",
                "custom:etcd-server"
              ]
              server_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
          },
          etcd-peer = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/etcd"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth", "ClientAuth"]
              allowed_domains = [
                "system:etcd-peer",
                "localhost",
                "*.${var.cluster_name}.${var.base_domain}",
                "custom:etcd-peer"
              ]
              client_flag     = true
              server_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
          },
          etcd-client = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/etcd"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ClientAuth"]
              allowed_domains = [
                "system:kube-apiserver-etcd-client",
                "system:etcd-healthcheck-client",
                "custom:etcd-client"
              ]
              client_flag = true
            }
          },
        }
      }
      front-proxy = {
        common_name  = "Front-proxy Intermediate CA",
        description  = "Front-proxy Intermediate CA"
        path         = "clusters/${var.cluster_name}/pki/front-proxy"
        root_path    = "clusters/${var.cluster_name}/pki/root"
        type         = "internal"
        organization = "Kubernetes"
        issuers = {
          front-proxy-client = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/front-proxy"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ClientAuth"]
              allowed_domains = [
                "system:kube-apiserver-front-proxy-client",
                "custom:kube-apiserver-front-proxy-client"
              ]
              client_flag = true
            }
          },
        }
      }
    }
    root_ca = {
      root = {
        CN          = "root",
        description = "root-ca"
        path        = "clusters/${var.cluster_name}/pki/root"
        root_path   = "${local.root_vault_path_pki}"
        common_name = "Kubernetes Root CA"
        type        = "internal"
      }
    }
    certificates = {
    }
  }
}

locals {
  kubernetes_issuers  = local.ssl.intermediate["kubernetes"].issuers
  etcd_issuers        = local.ssl.intermediate["etcd"].issuers
  front_proxy_issuers = local.ssl.intermediate["front-proxy"].issuers
}

locals {
  kubernetes_issuers_content = flatten([
    for name, kubernetes_issuer_content in "${local.kubernetes_issuers}" :
    {
      "${name}" = {
        value = merge("${local.ssl["global-args"]["issuer-args"]}", kubernetes_issuer_content["issuer-args"])
      }
    }
  ])
  kubernetes_issuers_content_map = { for item in local.kubernetes_issuers_content :
    keys(item)[0] => values(item)[0]
  }
  etcd_issuers_content = flatten([
    for name, etcd_issuer_content in "${local.etcd_issuers}" :
    {
      "${name}" = {
        value = merge("${local.ssl["global-args"]["issuer-args"]}", etcd_issuer_content["issuer-args"])
      }
    }
  ])
  etcd_issuers_content_map = { for item in local.etcd_issuers_content :
    keys(item)[0] => values(item)[0]
  }
  front_proxy_issuers_content = flatten([
    for name, front_proxy_issuer_content in "${local.front_proxy_issuers}" :
    {
      "${name}" = {
        value = merge("${local.ssl["global-args"]["issuer-args"]}", front_proxy_issuer_content["issuer-args"])
      }
    }
  ])
  front_proxy_issuers_content_map = { for item in local.front_proxy_issuers_content :
    keys(item)[0] => values(item)[0]
  }
  issuers_content_map_list = [
    "kubernetes_issuers_content_map",
    "etcd_issuers_content_map",
    "front_proxy_issuers_content_map"
  ]
}

output "name" {
  value = local.issuers_content_map_list
}
