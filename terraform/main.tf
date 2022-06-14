
resource "yandex_vpc_network" "cluster-vpc" {
  name = "${var.base_name}-vpc"
}

resource "yandex_vpc_subnet" "cluster-subnet" {
  for_each        = "${var.yc_availability_zones}"
  v4_cidr_blocks  = [each.value]
  zone            = "${each.key}"
  network_id      = "${yandex_vpc_network.cluster-vpc.id}"
  name            = "${var.base_name}-vpc-${each.key}" 
}

resource "yandex_compute_instance" "master" {
  for_each    = "${var.yc_availability_zones}"
  name        = "${var.base_name}-master-${index(keys(var.yc_availability_zones), each.key)}"
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
    user-data = "${local.cloud_init}"
  }
}

resource "yandex_lb_target_group" "master-tg" {
  name        = "${var.base_name}-master-target-group"
  region_id   = "ru-central1"

  dynamic "target" {
    for_each = "${var.yc_availability_zones}"
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
  value = "${local.cloud_init}"
}

