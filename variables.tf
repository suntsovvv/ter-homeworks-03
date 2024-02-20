###cloud vars

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  default     = "b1g6dgftb02k9esf1nmu"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  default     = "b1gksj8p2pj7de0re301"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDenMAd4hQiqCGq7tq31gEQPMPe1G1mE+Kn4l8qV9dFk user@study"

}
variable "count_vm" {
  default = { cores = 2, memory = 1, core_fraction = 20 }
}

variable "each_vm" {
  description = "vm_parameters"
  type = list(object({
    vm_name     = string,
    cpu         = number,
    ram         = number,
    disk_volume = number
  }))
  default = [ {
    vm_name     = "main"
    cpu         = 4
    ram         = 2
    disk_volume = 5
    },
    {
      vm_name     = "replica"
      cpu         = 2
      ram         = 1
      disk_volume = 8
  }]
}
