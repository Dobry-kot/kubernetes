
#### VPC ######
##-->
resource "yandex_vpc_network" "cluster-vpc" {
  name = "vpc.${var.cluster_name}"
}

#### SUBNETS ######
##-->
resource "yandex_vpc_subnet" "cluster-subnet" {
  for_each        = "${var.yc_availability_master_zones}"
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
  for_each  = "${var.yc_availability_master_zones}"
  zone_id   = yandex_dns_zone.zone1.id
  name      = "master-${index(keys(var.yc_availability_master_zones), each.key)}.${var.cluster_name}.${var.base_domain}."
  type      = "A"
  ttl       = 60
  data      = ["${yandex_compute_instance.master[each.key].network_interface.0.ip_address}"]
}

# resource "yandex_dns_recordset" "worker" {
#   for_each  = "${local.worker_replicas}"
#   zone_id   = yandex_dns_zone.zone1.id
#   name      = "worker-${index(keys(var.yc_availability_master_zones), each.key)}.${var.cluster_name}.${var.base_domain}."
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

  for_each    = "${var.yc_availability_master_zones}"
  name        = "master-${index(keys(var.yc_availability_master_zones), each.key)}-${var.cluster_name}"
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
        temporary_token = "${vault_approle_auth_backend_login.login.client_token}",
        cluster_name    = "${var.cluster_name}",
        base_domain     = "${var.base_domain}",
        ssh_key         = "${file("~/.ssh/id_rsa.pub")}"
        list_masters    = "${local.list_masters}"
        etcd_advertise_client_urls = "${local.etcd_advertise_client_urls}"
        instance_name   = "master-${index(keys(var.yc_availability_master_zones), each.key)}.${var.cluster_name}"
        instance_type   = "master"
        etcd_initial_cluster = "${local.etcd_initial_cluster}"
        kubeApiserverSaPub = "${tls_private_key.test.public_key_pem}"
        kubeApiserverSaPem = "${tls_private_key.test.private_key_pem}"
        
        })
  }
}

#### workers ######
##-->
resource "yandex_compute_instance" "workers" {

  count = 1
  name        = "worker-${count.index}-${var.cluster_name}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = "${var.worker_flavor.core}"
    memory        = "${var.worker_flavor.memory}"
    core_fraction = "${var.worker_flavor.core_fraction}"
  }

  boot_disk {
    initialize_params {
      image_id = "${var.base_os_image}"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.cluster-subnet["ru-central1-a"].id}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = templatefile("templates/cloud-init-worker.tftpl", { 
        temporary_token = "${vault_approle_auth_backend_login.login.client_token}",
        cluster_name    = "${var.cluster_name}",
        base_domain     = "${var.base_domain}",
        ssh_key         = "${file("~/.ssh/id_rsa.pub")}"
        instance_name   = "worker-${count.index}.${var.cluster_name}"
        instance_type   = "worker"
        })
  }
}
#### LB ######
##-->
resource "yandex_lb_target_group" "master-tg" {
  name        = "master-target-group-${var.cluster_name}"
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
    value = "${yandex_compute_instance.master[*].ru-central1-a.network_interface[*].nat_ip_address[*]}"
}


output "LB-API" {
    value = "${tolist(tolist(yandex_lb_network_load_balancer.master-lb.listener)[0].external_address_spec)[0].address}"
}
