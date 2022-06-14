

variable "cluster_name" {
  type = string
  default = "cluster-1"
}

variable "base_domain" {
  type = string
  default = "example.com"
}


variable "base_name" {
  type = string
  default = "firecube"
}

variable "base_os_image" {
  type = string
  default = "fd8l1com1tts4fr2dukt"
}

variable "master_flavor" {
  type = object({
    core          = string
    memory        = string
    core_fraction = string
  })
  default = {
    core          = 2
    memory        = 4
    core_fraction = 20
  }
}

variable "yc_availability_zones"{
  type = object({
    ru-central1-a = string
    ru-central1-b = string
    ru-central1-c = string
  })
  default = {
    ru-central1-a = "10.1.0.0/16"
    ru-central1-b = "10.2.0.0/16"
    ru-central1-c = "10.3.0.0/16"
  }
}


locals {
  base_vault_path_pki   = "clusters/${var.cluster_name}/pki"
  base_vault_path_kv    = "clusters/${var.cluster_name}/kv"
  root_vault_path_pki   = "pki-root"
}

locals {

    cloud_init = templatefile("templates/cloud-init.tftpl", { 
        temporary_token = "${vault_approle_auth_backend_login.login.client_token}",
        cluster_name    = "${var.cluster_name}",
        base_domain     = "${var.base_domain}",
        pki_path        = "${vault_mount.intermediate.path}",
        ssh_key         = "${file("~/.ssh/id_rsa.pub")}"
        }
    )

    vault_base_role = templatefile("templates/vault-base-role.tftpl", { 
        pki_path        = "${local.base_vault_path_pki}",
        cluster_name    = "${var.cluster_name}",
        pki_path_root   = "${local.root_vault_path_pki}",
        }
    )
}