# export YC_TOKEN=$(yc iam create-token)
# export YC_FOLDER_ID=$(yc config get folder-id)
# export YC_ZONE=$(yc config get compute-default-zone)


locals {
  base_date = formatdate("MM-DD-YYYY't'hh-mm", timestamp())
}

variable "YC_FOLDER_ID" {
  type = string
  default = env("YC_FOLDER_ID")
}

variable "YC_ZONE" {
  type = string
  default = env("YC_ZONE")
}

variable "YC_SUBNET_ID" {
  type = string
  default = env("YC_SUBNET_ID")
}

source "yandex" "packer" {
  folder_id           = "${var.YC_FOLDER_ID}"
  source_image_family = "almalinux-8"
  ssh_username        = "cloud-user"
  use_ipv4_nat        = "true"
  image_family        = "k8s"
  image_name          = "almalinux-${local.base_date }"
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
