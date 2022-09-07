locals {
  base_vault_path_kv         = "clusters/${var.cluster_name}/kv"
  root_vault_path_pki        = "pki-root"
  ssl = {
    global-args = {
        issuer-args = {
          allow_any_name                     = false
          allow_bare_domains                 = true
          allow_glob_domains                 = true
          allow_subdomains                   = false
          allowed_domains_template           = true
          basic_constraints_valid_for_non_ca = false
          code_signing_flag                  = false
          email_protection_flag              = false
          enforce_hostnames                  = false
          generate_lease                     = false
          key_bits                           = 4096
          key_type                           = "rsa"
          no_store                           = false
          require_cn                         = false
          ttl                                = 31540000
          use_csr_common_name                = true   
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
        issuers      = {
          kube-controller-manager-client = {
            backend                            = "clusters/${var.cluster_name}/pki/kubernetes"
            key_usage                          = ["DigitalSignature","KeyAgreement","ClientAuth"]
            allowed_domains                    = [
              "system:kube-controller-manager"
              ]
            organization                       = []
            client_flag                        = true
            server_flag                        = false
            allow_ip_sans                      = false
            allow_localhost                    = false
          },
          kube-apiserver-kubelet-client = {
            backend                            = "clusters/${var.cluster_name}/pki/kubernetes"
            key_usage                          = ["DigitalSignature","KeyAgreement","ClientAuth"]
            allowed_domains                    = [
              "custom:*",
              ]
            organization                       = ["system:masters"]
            client_flag                        = true
            server_flag                        = false
            allow_ip_sans                      = false
            allow_localhost                    = false
          },
          kube-apiserver = {
            backend                            = "clusters/${var.cluster_name}/pki/kubernetes"
            key_usage                          = ["DigitalSignature","KeyAgreement","ServerAuth"]
            allowed_domains                    = [
              "localhost",
              "kubernetes",
              "kubernetes.default",
              "kubernetes.default.svc",
              "kubernetes.default.svc.cluster",
              "kubernetes.default.svc.cluster.local",
              "custom:*",
              "api.${var.cluster_name}.${var.base_domain}"
              ]
            organization                       = []
            client_flag                        = false
            server_flag                        = true
            allow_ip_sans                      = true
            allow_localhost                    = true
          },
          kube-controller-manager-server = {
            backend                            = "clusters/${var.cluster_name}/pki/kubernetes"
            key_usage                          = ["DigitalSignature","KeyAgreement","ServerAuth"]
            allowed_domains                    = [
              "localhost",
              "kube-controller-manager.default",
              "kube-controller-manager.default.svc",
              "kube-controller-manager.default.svc.cluster",
              "kube-controller-manager.default.svc.cluster.local",
              "custom:kube-controller-manager"
              ]
            organization                       = []
            client_flag                        = false
            server_flag                        = true
            allow_ip_sans                      = true
            allow_localhost                    = true
          },
          kube-scheduler-server = {
            backend                            = "clusters/${var.cluster_name}/pki/kubernetes"
            key_usage                          = ["DigitalSignature","KeyAgreement","ServerAuth"]
            allowed_domains                    = [
              "localhost",
              "kube-scheduler.default",
              "kube-scheduler.default.svc",
              "kube-scheduler.default.svc.cluster",
              "kube-scheduler.default.svc.cluster.local",
              "custom:kube-scheduler"
              ]
            organization                       = []
            client_flag                        = false
            server_flag                        = true
            allow_ip_sans                      = true
            allow_localhost                    = true
          },
          kube-scheduler-client = {
            backend                            = "clusters/${var.cluster_name}/pki/kubernetes"
            key_usage                          = ["DigitalSignature","KeyAgreement","ClientAuth"]
            allowed_domains                    = [
              "system:kube-scheduler"
              ]
            organization                       = []
            client_flag                        = true
            server_flag                        = false
            allow_ip_sans                      = false
            allow_localhost                    = false
          },
          kubelet-server ={
            backend                            = "clusters/${var.cluster_name}/pki/kubernetes"
            key_usage                          = ["DigitalSignature","KeyAgreement","ServerAuth"]
            allowed_domains                    = [
              "localhost",
              "*.${var.cluster_name}.${var.base_domain}",
              "system:node:*"
              ]
            organization                       = [
                "system:nodes",
            ]
            client_flag                        = false
            server_flag                        = true
            allow_ip_sans                      = true
            allow_localhost                    = true
          }
          kubelet-client = {
            backend                            = "clusters/${var.cluster_name}/pki/kubernetes"
            key_usage                          = ["DigitalSignature","KeyAgreement","ClientAuth"]
            allowed_domains                    = [
                "system:node:*",
              ]
            organization                       = [
                "system:nodes",
            ]
            client_flag                        = true
            server_flag                        = false
            allow_ip_sans                      = false
            allow_localhost                    = false
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
        issuers      = {
          etcd-server = {
            backend                            = "clusters/${var.cluster_name}/pki/etcd"
            key_usage                          = ["DigitalSignature","KeyAgreement","ServerAuth"]
            allowed_domains                    = [
              "system:etcd-server",
              "localhost",
              "*.${var.cluster_name}.${var.base_domain}",
              "custom:*"
              ]
            organization                       = []
            client_flag                        = false
            server_flag                        = true
            allow_ip_sans                      = true
            allow_localhost                    = true
          },
          etcd-peer = {
            backend                            = "clusters/${var.cluster_name}/pki/etcd"
            key_usage                          = ["DigitalSignature","KeyAgreement","ServerAuth","ClientAuth"]
            allowed_domains                    = [
              "system:etcd-peer",
              "localhost",
              "*.${var.cluster_name}.${var.base_domain}",
              "custom:*"
              ]
            organization                       = []
            client_flag                        = true
            server_flag                        = true
            allow_ip_sans                      = true
            allow_localhost                    = true
          },
          etcd-client = {
            backend                            = "clusters/${var.cluster_name}/pki/etcd"
            key_usage                          = ["DigitalSignature","KeyAgreement","ClientAuth"]
            allowed_domains                    = [
              "system:kube-apiserver-etcd-client",
              "system:etcd-healthcheck-client",
              "custom:*"
              ]
            organization                       = []
            client_flag                        = true
            server_flag                        = false
            allow_ip_sans                      = false
            allow_localhost                    = false
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
        issuers      = {
          front-proxy-client = {
            backend                            = "clusters/${var.cluster_name}/pki/front-proxy"
            key_usage                          = ["DigitalSignature","KeyAgreement","ClientAuth"]
            allowed_domains                    = [
              "system:kube-apiserver-front-proxy-client",
              "custom:*"
              ]
            organization                       = []
            client_flag                        = true
            server_flag                        = false
            allow_ip_sans                      = false
            allow_localhost                    = false
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