# export YC_TOKEN=$(yc iam create-token)

locals {
  base_date = formatdate("MMM-DD-YYYY", timestamp())
}

source "yandex" "packer" {
  folder_id           = "b1g7220ns3r5dts1lha3"
  source_image_family = "almalinux-8"
  ssh_username        = "cloud-user"
  use_ipv4_nat        = "true"
  image_family        = "k8s"
  image_name          = "almalinux-06-01-00"
  subnet_id           = "e9bln6ttrrilu88m6h7d"
  disk_type           = "network-hdd"
  zone                = "ru-central1-a"
}

build {
  sources = ["source.yandex.packer"]
  provisioner "ansible" {
      playbook_file = "./plays/preparation-nodes.yaml"
      extra_arguments = ["-e", "ansible_become=true", "-e", "packer_builder=true" ]
    }
}
