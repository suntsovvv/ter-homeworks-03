resource "yandex_compute_disk" "disks" {
  count   = 3
  name  = "disk-${count.index + 1}"
  type = "network-hdd"
  size  = 1

}


resource "yandex_compute_instance" "storage" {
  name = "storage"
  resources {
    cores = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
    image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
        }
  }

  dynamic "secondary_disk" {

   for_each = { for stor in yandex_compute_disk.disks[*]: stor.name=> stor }
   content {

     disk_id = secondary_disk.value.id
   }
  }
  network_interface {
     subnet_id = yandex_vpc_subnet.develop.id
     nat     = true
  }

  metadata = local.vms_metadata
}

