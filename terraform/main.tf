
resource "yandex_vpc_network" "cluster-vpc" {
  name = "${var.base_name}-vpc"
}

resource "yandex_vpc_subnet" "cluster-subnet" {
  for_each        = "${var.yc_availability_master_zones}"
  v4_cidr_blocks  = [each.value]
  zone            = "${each.key}"
  network_id      = "${yandex_vpc_network.cluster-vpc.id}"
  name            = "${var.base_name}-vpc-${each.key}" 
}

resource "yandex_dns_zone" "zone1" {
  name        = "${var.base_name}-dns-zone"
  description = "desc"
  zone             = "${var.base_domain}."
  public           = false
  private_networks = [yandex_vpc_network.cluster-vpc.id]
}

resource "yandex_dns_recordset" "rs1" {
  for_each    = "${var.yc_availability_master_zones}"
  zone_id = yandex_dns_zone.zone1.id
  name    = "${var.base_name}-master-${index(keys(var.yc_availability_master_zones), each.key)}.${var.cluster_name}.${var.base_domain}."
  type    = "A"
  ttl     = 60
  data    = ["${yandex_compute_instance.master[each.key].network_interface.0.ip_address}"]
}

resource "yandex_compute_instance" "master" {

  for_each    = "${var.yc_availability_master_zones}"
  name        = "${var.base_name}-master-${index(keys(var.yc_availability_master_zones), each.key)}"
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
    user-data = templatefile("templates/cloud-init.tftpl", { 
        temporary_token = "${vault_approle_auth_backend_login.login.client_token}",
        cluster_name    = "${var.cluster_name}",
        base_domain     = "${var.base_domain}",
        certs           = "${local.ssl}",
        ssh_key         = "${file("~/.ssh/id_rsa.pub")}"
        list_masters    = "${local.list_masters}"
        etcd_advertise_client_urls = "${local.etcd_advertise_client_urls}"
        instance_name   = "${var.base_name}-master-${index(keys(var.yc_availability_master_zones), each.key)}"
        base_domain     = "${var.base_domain}"
        # lb_api_ip       = "${yandex_lb_network_load_balancer.master-lb.listener}"
        etcd_initial_cluster = "${local.etcd_initial_cluster}"
        })
  }
}

resource "yandex_lb_target_group" "master-tg" {
  name        = "${var.base_name}-master-target-group"
  region_id   = "ru-central1"

  dynamic "target" {
    for_each = "${var.yc_availability_master_zones}"
    content {
      subnet_id = "${yandex_vpc_subnet.cluster-subnet[target.key].id}"
      address   = "${yandex_compute_instance.master[target.key].network_interface.0.ip_address}"
    }
  }
}

resource "yandex_lb_network_load_balancer" "master-lb" {
  name = "${var.base_name}-lb-api"
  listener {
    name = "${var.base_name}-api-listener"
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
    value = "${yandex_compute_instance.master[*].ru-central1-a.network_interface[*].nat_ip_address[*]}"
}

