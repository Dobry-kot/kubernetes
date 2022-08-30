variable "YC_FOLDER_ID" {
  type = string
  default = env("YC_FOLDER_ID")
}

variable "YC_ZONE" {
  type = string
  default = "ru-central1-a"
}

variable "YC_SUBNET_ID" {
  type = string
  default = "e9bln6ttrrilu88m6h7d"
}


source "yandex" "packer" {
  folder_id           = "${var.YC_FOLDER_ID}"
  source_image_family = "almalinux-8"
  ssh_username        = "almalinux"
  use_ipv4_nat        = "true"
  image_family        = "k8s"
  image_name          = "almalinux-8"
  subnet_id           = "${var.YC_SUBNET_ID}"
  disk_type           = "network-hdd"
  zone                = "${var.YC_ZONE}"
}

build {
  sources = ["source.yandex.packer"]
  provisioner "ansible" {
      playbook_file = "./plays/preparation-nodes.yaml"
      extra_arguments = ["-e", "ansible_become=true", "-e", "packer_builder=true" ]
    }
}
