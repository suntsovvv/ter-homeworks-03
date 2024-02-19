# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»
### Задание 1   
![image](https://github.com/suntsovvv/ter-homeworks-03/assets/154943765/72ed2a77-5967-4054-8c3b-07ddc47eccbf)
### Задание 2   
1 -   
```hcl
data "yandex_compute_image" "ubuntu-2004-lts" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "example" {
  count = 2
  depends_on = [yandex_compute_instance.second]
  name        = "web-${count.index + 1}"
  platform_id = "standard-v1"

  resources {
    cores         = var.count_vm.cores
    memory        = var.count_vm.memory
    core_fraction = var.count_vm.core_fraction
    
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = "network-hdd"
      size     = 5
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
```
![image](https://github.com/suntsovvv/ter-homeworks-03/assets/154943765/de064eb1-4819-4fe7-8118-9534f1c6d43b)
![image](https://github.com/suntsovvv/ter-homeworks-03/assets/154943765/061f23b2-665c-49ab-86b4-a21553e2d5f7)
![image](https://github.com/suntsovvv/ter-homeworks-03/assets/154943765/c9d7deab-4781-46b2-b6af-87a2d0275d3c)
2 -   
```hcl
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

```
![image](https://github.com/suntsovvv/ter-homeworks-03/assets/154943765/2394e4bb-c9bd-42b3-a6e3-503ca860afef)   
3 -   
```hcl
resource "yandex_compute_instance" "example" {
  count = 2
  depends_on = [yandex_compute_instance.second]
  name        = "web-${count.index + 1}"
  platform_id = "standard-v1"
```
4 -   
```hcl
locals{
    vms_metadata = {
      serial-port-enable = 1
      ssh-key  = "ubuntu:${file("~/.ssh/id_ed25519.pub")} " 
    }
}

```
