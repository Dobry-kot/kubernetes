
variable "bastion_cidr" {
  type = list(string)
  default = [
    "176.112.235.30/32"
  ]
}

variable "instance_name" {
  type = string
  default = "default"
}
variable "vault_config" {
  type = object({
    server          = string
    caBundle        = string
    tlsInsecure     = bool
  })
  default = {
    server      = "http://51.250.67.8:9200"
    caBundle    = ""
    tlsInsecure = true
  }
}

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
  default = "fd82c7e0bmhu1phq9dhl"
}

variable "master_flavor" {
  type = object({
    core          = string
    memory        = string
    core_fraction = string
  })
  default = {
    core          = 4
    memory        = 8
    core_fraction = 100
  }
}

variable "worker_flavor" {
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



variable "availability_zones"{
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
  worker_replicas = range(3)
}
