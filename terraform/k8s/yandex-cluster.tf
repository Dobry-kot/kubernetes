
#### VPC ######
##-->
resource "yandex_vpc_network" "cluster-vpc" {
  name = "vpc.${var.cluster_name}"
}

#### SUBNETS ######
##-->
resource "yandex_vpc_subnet" "cluster-subnet" {
  for_each        = "${var.availability_zones}"
  v4_cidr_blocks  = [each.value]
  zone            = "${each.key}"
  network_id      = "${yandex_vpc_network.cluster-vpc.id}"
  name            = "vpc-${each.key}-${var.cluster_name}" 
}

#### DNS ######
##-->
resource "yandex_dns_zone" "zone1" {
  name             = "dns-zone-${var.cluster_name}"
  description      = "desc"
  zone             = "${var.cluster_name}.${var.base_domain}."
  public           = false
  private_networks = [yandex_vpc_network.cluster-vpc.id]
}

resource "yandex_dns_recordset" "master" {
  for_each  = "${var.availability_zones}"
  zone_id   = yandex_dns_zone.zone1.id
  name      = "${var.master-configs.group}-${index(keys(var.availability_zones), each.key)}.${var.cluster_name}.${var.base_domain}."
  type      = "A"
  ttl       = 60
  data      = ["${yandex_compute_instance.master[each.key].network_interface.0.ip_address}"]
}

# resource "yandex_dns_recordset" "worker" {
#   for_each  = "${local.worker_replicas}"
#   zone_id   = yandex_dns_zone.zone1.id
#   name      = "worker-${index(keys(var.availability_zones), each.key)}.${var.cluster_name}.${var.base_domain}."
#   type      = "A"
#   ttl       = 60
#   data      = ["${yandex_compute_instance.master[each.key].network_interface.0.ip_address}"]
# }


resource "yandex_dns_recordset" "api" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "api.${var.cluster_name}.${var.base_domain}."
  type    = "A"
  ttl     = 60
  data    = "${(tolist(yandex_lb_network_load_balancer.master-lb.listener)[0].external_address_spec)[*].address}"
}



#### MASTERS ######
##-->
resource "yandex_compute_instance" "master" {

  for_each    = "${var.availability_zones}"
  name        = "${var.master-configs.group}-${index(keys(var.availability_zones), each.key)}-${var.cluster_name}"
  platform_id = "standard-v1"
  zone        = "${each.key}"

  resources {
    cores         = "${var.master_flavor.core}"
    memory        = "${var.master_flavor.memory}"
    core_fraction = "${var.master_flavor.core_fraction}"
  }

  boot_disk {
    initialize_params {
      image_id = "${var.base_os_image}"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.cluster-subnet[each.key].id}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = templatefile("templates/cloud-init-master.tftpl", {

        ssh_key               = file("~/.ssh/id_rsa.pub")
        base_local_path_certs = local.base_local_path_certs
        ssl                   = local.ssl
        kubelet-config        = local.kubelet-config
        instance_type         = var.master-configs.group
        base_path             = var.base_path
        instance_name         = "${var.master-configs.group}-${index(keys(var.availability_zones), each.key)}.${var.cluster_name}.${var.base_domain}"

        key_keeper_config                 = templatefile("templates/key-keeper-config.tftpl", {
          intermediates                   = local.ssl.intermediate
          base_local_path_vault           = local.base_local_path_vault
          base_vault_path_approle         = local.base_vault_path_approle
          base_certificate_atrs           = local.ssl.global-args.key-keeper-args
          cluster_name                    = var.cluster_name
          base_domain                     = var.base_domain
          vault_config                    = var.vault_config
          bootstrap_tokens_ca             = "${vault_approle_auth_backend_login.kubernetes-ca-login}"
          bootstrap_tokens_sign           = "${vault_approle_auth_backend_login.kubernetes-sign-login}"
          availability_zone               = "${each.key}"
          instance_name                   = "${var.master-configs.group}-${index(keys(var.availability_zones), each.key)}.${var.cluster_name}"
        })
        etcd-manifest                     = templatefile("templates/manifests/etcd.yaml.tftpl", {
          etcd_initial_cluster            = local.etcd_initial_cluster
          base_local_path_certs           = local.base_local_path_certs
          ssl                             = local.ssl
          cluster_name                    = var.cluster_name
          base_domain                     = var.base_domain
          etcd-image                      = var.etcd-image.repository
          etcd-version                    = var.etcd-image.version
          instance_name                   = "${var.master-configs.group}-${index(keys(var.availability_zones), each.key)}.${var.cluster_name}"
        })
        kube-apiserver-manifest           = templatefile("templates/manifests/kube-apiserver.yaml.tftpl", {
          etcd_advertise_client_urls      = local.etcd_advertise_client_urls
          service_cidr                    = local.service_cidr
          base_local_path_certs           = local.base_local_path_certs
          ssl                             = local.ssl
          kube-apiserver-image            = var.kube-apiserver-image
          kubernetes-version              = var.kubernetes-version
          base_path                       = var.base_path
        })
        kube-controller-manager-manifest  = templatefile("templates/manifests/kube-controller-manager.yaml.tftpl", {
          service_cidr                    = local.service_cidr
          base_local_path_certs           = local.base_local_path_certs
          ssl                             = local.ssl
          kube-controller-manager-image   = var.kube-controller-manager-image
          kubernetes-version              = var.kubernetes-version
          base_path                       = var.base_path
        })
        kube-scheduler-manifest           = templatefile("templates/manifests/kube-scheduler.yaml.tftpl", {
          base_local_path_certs           = local.base_local_path_certs
          ssl                             = local.ssl
          kube-scheduler-image            = var.kube-scheduler-image
          kubernetes-version              = var.kubernetes-version
          base_path                       = var.base_path
        })
      })
  }
}

### workers ######
#-->
# resource "yandex_compute_instance" "workers" {

#   count = 0
#   name        = "worker-${count.index}-${var.cluster_name}"
#   platform_id = "standard-v1"
#   zone        = "ru-central1-a"

#   resources {
#     cores         = "${var.worker_flavor.core}"
#     memory        = "${var.worker_flavor.memory}"
#     core_fraction = "${var.worker_flavor.core_fraction}"
#   }

#   boot_disk {
#     initialize_params {
#       image_id = "${var.base_os_image}"
#     }
#   }

#   network_interface {
#     subnet_id = "${yandex_vpc_subnet.cluster-subnet["ru-central1-a"].id}"
#     nat = true
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#     user-data = templatefile("templates/cloud-init-worker.tftpl", { 
#         temporary_token = "",
#         cluster_name    = "${var.cluster_name}",
#         base_domain     = "${var.base_domain}",
#         ssh_key         = "${file("~/.ssh/id_rsa.pub")}"
#         instance_name   = "worker-${count.index}.${var.cluster_name}"
#         instance_type   = "worker"
#         key_keeper_config = templatefile("templates/key-keeper-config.tfttpl", { 
#           intermediates           = "${local.ssl.intermediate}",
#           cluster_name            = var.cluster_name
#           base_local_path_vault   = local.base_local_path_vault
#           base_vault_path_approle = local.base_vault_path_approle
#           base_certificate_atrs   = "${local.ssl.global-args.key-keeper-args}"
#           vault_config            = var.vault_config
#           instance_name           = "worker-${count.index}.${var.cluster_name}"
#           bootstrap_tokens_ca     = "${vault_approle_auth_backend_login.kubernetes-ca-login}"
#           bootstrap_tokens_sign   = "${vault_approle_auth_backend_login.kubernetes-sign-login}"
#         })
#       })
#   }
# }
#### LB ######
##-->
resource "yandex_lb_target_group" "master-tg" {
  name        = "${var.master-configs.group}-target-group-${var.cluster_name}"
  region_id   = "ru-central1"

  dynamic "target" {
    for_each = "${var.availability_zones}"
    content {
      subnet_id = "${yandex_vpc_subnet.cluster-subnet[target.key].id}"
      address   = "${yandex_compute_instance.master[target.key].network_interface.0.ip_address}"
    }
  }
}

resource "yandex_lb_network_load_balancer" "master-lb" {
  name = "lb-api-${var.cluster_name}"
  listener {
    name = "api-listener-${var.cluster_name}"
    port = 6443
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = "${yandex_lb_target_group.master-tg.id}"

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 6443

      }
    }
  }
}

output "cloud_init" {
    value = "${yandex_compute_instance.master[*].ru-central1-a.network_interface[*].nat_ip_address}"
}


output "LB-API" {
    value = "${tolist(tolist(yandex_lb_network_load_balancer.master-lb.listener)[0].external_address_spec)[0].address}"
}