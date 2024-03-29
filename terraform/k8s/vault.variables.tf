locals {
  base_local_path_certs   = "/etc/kubernetes/pki"
  base_local_path_vault   = "/var/lib/key-keeper/vault"
  base_vault_path_kv      = "clusters/${var.cluster_name}/kv"
  base_vault_path_approle = "clusters/${var.cluster_name}/approle"
  root_vault_path_pki     = "pki-root"
  
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
      key-keeper-args = {
        spec = {
          subject = {
            commonName          = ""
            country             = ""
            localite            = ""
            organization        = ""
            organizationalUnit  = ""
            province            = ""
            postalCode          = ""
            streetAddress       = ""
            serialNumber        = ""
          }
          privateKey = {
            algorithm = "RSA"
            encoding  = "PKCS1"
            size      = 4096
          }
          ttl         = "10m"
          ipAddresses = {}
          hostnames   = []
          usages      = []
        }
        renewBefore   = "5m"
        trigger       = []

      }
    }

    intermediate = {
      kubernetes-ca = {
        labels = {
          type = "worker"
        }
        common_name   = "Kubernetes Intermediate CA",
        description   = "Kubernetes Intermediate CA"
        path          = "clusters/${var.cluster_name}/pki/kubernetes"
        root_path     = "clusters/${var.cluster_name}/pki/root"
        host_path     = "${local.base_local_path_certs}/ca"
        type          = "internal"
        organization  = "Kubernetes"
        exportedKey  = false
        generate     = false
        default_lease_ttl_seconds = 321408000
        max_lease_ttl_seconds     = 321408000
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
            certificates = {
              kube-controller-manager-client = {
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "system:kube-controller-manager"
                    }
                    usages = [
                      "client auth"
                    ]
                  }
                  host_path     = "${local.base_local_path_certs}/certs/kube-controller-manager"
                }
              }

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
            certificates = {
              kube-controller-manager-server = {
                labels = {
                  component = "kube-controller-manager" 
                }
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "custom:kube-controller-manager"
                    }
                    usages = [
                      "server auth",
                    ]
                    hostnames = [
                      "localhost",
                      "kube-controller-manager.default",
                      "kube-controller-manager.default.svc",
                      "kube-controller-manager.default.svc.cluster",
                      "kube-controller-manager.default.svc.cluster.local",
                    ]
                    ipAddresses = {
                      interfaces = [
                        "lo",
                        "eth*"
                      ]
                    }
                  }
                  host_path = "${local.base_local_path_certs}/certs/kube-controller-manager"
                }
              }

            }
          },
          kube-apiserver-kubelet-client = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ClientAuth"]
              allowed_domains = [
                "custom:kube-apiserver-kubelet-client",
                "custom:terrafor-kubeconfig",
              ]
              organization = ["system:masters"]
              client_flag  = true
            }
            certificates = {
              kube-apiserver-kubelet-client = {
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "custom:kube-apiserver-kubelet-client",
                      organizationalUnit = [
                        "system:masters"
                        ]
                    }
                    usages = [
                      "client auth"
                    ]
                  }
                  host_path = "${local.base_local_path_certs}/certs/kube-apiserver"
                }
              }
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
            certificates = {
              kube-apiserver = {
                labels = {
                  component = "kube-apiserver" 
                }
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "custom:kube-apiserver"
                    }
                    usages = [
                      "server auth",
                    ]
                    hostnames = [
                      "localhost",
                      "kubernetes",
                      "kubernetes.default",
                      "kubernetes.default.svc",
                      "kubernetes.default.svc.cluster",
                      "kubernetes.default.svc.cluster.local",
                      "api.${var.cluster_name}.${var.base_domain}"
                    ]
                    ipAddresses = {
                      static = [
                        local.api_address
                      ]
                      interfaces = [
                        "lo",
                        "eth*"
                      ]
                      dnsLookup = [
                        "api.${var.cluster_name}.${var.base_domain}"
                      ]
                    }
                  }
                  host_path = "${local.base_local_path_certs}/certs/kube-apiserver"
                }
              }
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
            certificates = {
              kube-scheduler-server = {
                labels = {
                  component = "kube-scheduler" 
                }
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "custom:kube-scheduler"
                    }
                    usages = [
                      "server auth",
                    ]
                    hostnames = [
                      "localhost",
                      "kube-scheduler.default",
                      "kube-scheduler.default.svc",
                      "kube-scheduler.default.svc.cluster",
                      "kube-scheduler.default.svc.cluster.local",
                    ]
                    ipAddresses = {
                      interfaces = [
                        "lo",
                        "eth*"
                      ]
                    }
                  }
                  host_path = "${local.base_local_path_certs}/certs/kube-scheduler"
                }
              }
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
            certificates = {
              kube-scheduler-client = {
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "system:kube-scheduler"
                    }
                    usages = [
                      "client auth"
                    ]
                  }
                  host_path = "${local.base_local_path_certs}/certs/kube-scheduler"
                }
              }
            }
          },
          kubelet-peer-k8s-certmanager = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth","ClientAuth"]
              allowed_domains = [
                "localhost",
                "*.${var.cluster_name}.${var.base_domain}",
                "${ var.instance_name }.${var.cluster_name}.${var.base_domain}",
                "system:node:*"
              ]
              organization = [
                "system:nodes",
              ]
              server_flag     = true
              client_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
            certificates = {}
          }
          kubelet-server = {
            labels = {
              type = "worker"
            }
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/kubernetes"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth"]
              allowed_domains = [
                "localhost",
                "*.${var.cluster_name}.${var.base_domain}",
                "${ var.instance_name }.${var.cluster_name}.${var.base_domain}",
                "system:node:*"
              ]
              organization = [
                "system:nodes",
                "system:authenticated"
              ]
              server_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
            certificates = {
              kubelet-server = {
                labels = {
                  component = "kubelet"
                  trigger-command = "['systemctl','restart','kubelet']"
                }
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "system:node:${ var.instance_name }.${var.cluster_name}.${var.base_domain}"
                      organizations = [
                        "system:nodes"
                      ]
                    }
                    usages = [
                      "server auth",
                    ]
                    hostnames = [
                      "localhost",
                    ]
                    ipAddresses = {
                      interfaces = [
                        "lo",
                        "eth*"
                      ]
                      dnsLookup = []
                    }
                    # ttl = "200h"
                  }
                  host_path     = "${local.base_local_path_certs}/certs/kubelet"
                  # renewBefore   = "100h"
                }
              }
            }
          }
          kubelet-client = {
            labels = {
              type = "worker"
            }
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
            certificates = {
              kubelet-client = {
                labels = {
                  component = "kubelet"
                  trigger-command = "['systemctl','restart','kubelet']"
                }
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "system:node:${ var.instance_name }.${var.cluster_name}.${var.base_domain}"
                      organization = [
                        "system:nodes"
                      ]
                    }
                    usages = [
                      "client auth"
                    ]
                  }
                  host_path = "${local.base_local_path_certs}/certs/kubelet"
                }
              }
            }
          },
        }
      }
      etcd-ca = {
        common_name  = "ETCD Intermediate CA",
        description  = "ETCD Intermediate CA"
        path         = "clusters/${var.cluster_name}/pki/etcd"
        root_path    = "clusters/${var.cluster_name}/pki/root"
        host_path    = "${local.base_local_path_certs}/ca"
        type         = "internal"
        organization = "Kubernetes"
        exportedKey  = false
        generate     = false
        default_lease_ttl_seconds = 321408000
        max_lease_ttl_seconds     = 321408000
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
            certificates = {
              # etcd-server = {
              #   labels = {
              #     component = "etcd"
              #   }
              #   key-keeper-args = {
              #     spec = {
              #       subject = {
              #         commonName = "system:etcd-server"
              #       }
              #       usages = [
              #         "server auth",
              #       ]
              #       hostnames = [
              #         "localhost",
              #       ]
              #       ipAddresses = {
              #         interfaces = [
              #           "lo",
              #           "eth*"
              #         ]
              #         dnsLookup = []
              #       }
              #     }
              #     host_path = "${local.base_local_path_certs}/certs/etcd"
              #   }
              # }
            }
          },
          etcd-peer = {
            issuer-args = {
              backend   = "clusters/${var.cluster_name}/pki/etcd"
              key_usage = ["DigitalSignature", "KeyAgreement", "KeyEncipherment", "ServerAuth", "ClientAuth"]
              allowed_domains = [
                "system:etcd-peer",
                "system:etcd-server",
                "localhost",
                "*.${var.cluster_name}.${var.base_domain}",
                "custom:etcd-peer",
                "custom:etcd-server"
              ]
              client_flag     = true
              server_flag     = true
              allow_ip_sans   = true
              allow_localhost = true
            }
            certificates = {
              etcd-server = {
                labels = {
                  component = "etcd"
                }
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "system:etcd-server"
                    }
                    usages = [
                      "server auth",
                      "client auth"
                    ]
                    hostnames = [
                      "localhost",
                    ]
                    ipAddresses = {
                      interfaces = [
                        "lo",
                        "eth*"
                      ]
                      dnsLookup = []
                    }
                  }
                  host_path = "${local.base_local_path_certs}/certs/etcd"
                }
              }
              etcd-peer = {
                labels = {
                  component = "etcd"
                }
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "system:etcd-peer"
                    }
                    usages = [
                      "server auth",
                      "client auth"
                    ]
                    hostnames = [
                      "localhost",
                    ]
                    ipAddresses = {
                      interfaces = [
                        "lo",
                        "eth*"
                      ]
                      dnsLookup = []
                    }
                  }
                  host_path = "${local.base_local_path_certs}/certs/etcd"
                }
              }
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
            certificates = {
              kube-apiserver-etcd-client = {
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "system:kube-apiserver-etcd-client"
                    }
                    usages = [
                      "client auth"
                    ]
                  }
                  host_path = "${local.base_local_path_certs}/certs/kube-apiserver"
                }
              }
            }
          },
        }
      }
      front-proxy-ca = {
        common_name  = "Front-proxy Intermediate CA",
        description  = "Front-proxy Intermediate CA"
        path         = "clusters/${var.cluster_name}/pki/front-proxy"
        root_path    = "clusters/${var.cluster_name}/pki/root"
        host_path    = "${local.base_local_path_certs}/ca"
        type         = "internal"
        organization = "Kubernetes"
        exportedKey  = false
        generate     = false
        default_lease_ttl_seconds = 321408000
        max_lease_ttl_seconds     = 321408000
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
            certificates = {
              front-proxy-client = {
                key-keeper-args = {
                  spec = {
                    subject = {
                      commonName = "custom:kube-apiserver-front-proxy-client"
                    }
                    usages = [
                      "client auth"
                    ]
                  }
                  host_path = "${local.base_local_path_certs}/certs/kube-apiserver"
                }
              }
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
        default_lease_ttl_seconds = 321408000
        max_lease_ttl_seconds     = 321408000
      }
    }
  }
  
  secrets = {
    kube-apiserver-sa = {
      path = local.base_vault_path_kv
      keys = {
        public = {
          host_path = "${local.base_local_path_certs}/certs/kube-apiserver/kube-apiserver-sa.pub"
        }
        private = {
          host_path = "${local.base_local_path_certs}/certs/kube-apiserver/kube-apiserver-sa.pem"
        }
      }
    }
  }
}

locals {
  issuers_content = flatten([
  for name in keys(local.ssl.intermediate) : [
    for issuer_name,issuer in local.ssl.intermediate[name].issuers : [
      for availability_zone_name in sort(keys(var.availability_zones)):  
        {"${name}:${issuer_name}:${availability_zone_name}" = merge("${local.ssl["global-args"]["issuer-args"]}", issuer["issuer-args"])}
        ]
      ]
    ]
  )
  issuers_content_map = { for item in local.issuers_content :
    keys(item)[0] => values(item)[0]
  }

  access_cidr_availability_zones = flatten([for zone_name in keys(var.availability_zones) : [var.availability_zones[zone_name]]])
  access_cidr_vault = "${concat(local.access_cidr_availability_zones, var.bastion_cidr)}"

}
