
resource "yandex_compute_instance" "second" {
  for_each = toset (keys({for i, r in var.each_vm:  i => r}) )
  
name = var.each_vm[each.value]["vm_name"]

   resources {
    cores         = var.each_vm[each.value]["cpu"]
    memory        = var.each_vm[each.value]["ram"]
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = "network-hdd"
      size     =  var.each_vm[each.value]["disk_volume"]
    }
  }

  metadata = local.vms_metadata

  scheduling_policy { preemptible = true }

  network_interface {

    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = true
  }
  allow_stopping_for_update = true
}
