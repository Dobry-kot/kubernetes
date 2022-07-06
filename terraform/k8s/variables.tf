

variable "cluster_name" {
  type = string
  default = "default"
}

variable "base_domain" {
  type = string
  default = "dobry-kot.ru"
}

variable "base_os_image" {
  type = string
  default = "fd8m05qkt5heqme34q9p"
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

variable "yc_availability_master_zones"{
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
  list_masters               = formatlist("master-%s.${var.cluster_name}.${var.base_domain}", range(length(var.yc_availability_master_zones)))
  etcd_list_servers          = formatlist("https://master-%s.${var.cluster_name}.${var.base_domain}:2379", range(length(var.yc_availability_master_zones)))
  etcd_list_initial_cluster  = formatlist("master-%s.${var.cluster_name}.${var.base_domain}=https://master-%s.${var.cluster_name}.${var.base_domain}:2380", range(length(var.yc_availability_master_zones)), range(length(var.yc_availability_master_zones)))

  etcd_advertise_client_urls = join(",", local.etcd_list_servers)
  etcd_initial_cluster       = join(",", local.etcd_list_initial_cluster)
}

locals {
    vault_base_role = templatefile("templates/vault-base-role.tftpl", { 
        pki_path           = "${local.ssl}",
        cluster_name       = "${var.cluster_name}",
        pki_path_root      = "${local.root_vault_path_pki}",
        base_vault_path_kv = "${local.base_vault_path_kv}",
        }
    )
}