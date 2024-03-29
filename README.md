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
  count = var.count_vm.count
  depends_on = [yandex_compute_instance.second]
  name        = "${var.count_vm.name}-${count.index + 1}"
  platform_id = var.count_vm.platform_id

  resources {
    cores         = var.count_vm.cores
    memory        = var.count_vm.memory
    core_fraction = var.count_vm.core_fraction
    
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = var.vm_disks_cuontvm.type
      size     = var.vm_disks_cuontvm.size
    }
  }

  metadata = local.vms_metadata

  

   scheduling_policy { preemptible = var.sh_pol }

  network_interface {

    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = var.vm_nat
  }
  
  allow_stopping_for_update = var.allow_stopping
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
    core_fraction = var.each_vm[each.value]["core_fraction"]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type     = var.vm_disks_cuontvm.type
      size     =  var.each_vm[each.value]["disk_volume"]
    }
  }

  metadata = local.vms_metadata

   scheduling_policy { preemptible = var.sh_pol }

  network_interface {

    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
    nat                = var.vm_nat
  }
  allow_stopping_for_update = var.allow_stopping
}

```
![image](https://github.com/suntsovvv/ter-homeworks-03/assets/154943765/2394e4bb-c9bd-42b3-a6e3-503ca860afef)   
3 -   
```hcl
resource "yandex_compute_instance" "example" {
  count = var.count_vm.count
  depends_on = [yandex_compute_instance.second]
  name        = "${var.count_vm.name}-${count.index + 1}"
  platform_id = var.count_vm.platform_id
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
### Задание 3    
```hcl

resource "yandex_compute_disk" "disks" {
  count   = var.vm_disks_stor.count
  name  = "${var.vm_disks_stor.name}-${count.index + 1}"
  type = var.vm_disks_stor.type
  size  = var.vm_disks_stor.size

}


resource "yandex_compute_instance" "storage" {
  name = var.vm_storage.name
  resources {
    cores = var.vm_storage.cores
    memory = var.vm_storage.memory
    core_fraction = var.vm_storage.core_fraction
  }

  boot_disk {
    initialize_params {
    image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
        }
  }

  dynamic "secondary_disk" {
   for_each =  yandex_compute_disk.disks
     content {

     disk_id = secondary_disk.value.id
     
   }
  }
  scheduling_policy { preemptible = var.sh_pol }
  network_interface {
     subnet_id = yandex_vpc_subnet.develop.id
     nat     = var.vm_nat
  }
 allow_stopping_for_update = var.allow_stopping
  metadata = local.vms_metadata
}
```
![image](https://github.com/suntsovvv/ter-homeworks-03/assets/154943765/8b243315-9292-4e69-8bd5-389d030b18aa)   
### Задание 4
Файл inventory.tftpl:
```
[webservers]

%{~ for i in webservers ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"]}
%{~ endfor ~}

[databases]

%{~ for i in databases ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"]}
%{~ endfor ~}

[storage]

%{~ for i in storage ~}
${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]} fqdn=${i["fqdn"]}
%{~ endfor ~}
```
Файл inventory:
```
[webservers]
web-1   ansible_host=158.160.37.193 fqdn=fhmjbrh67g7akcu7iql2.auto.internalweb-2   ansible_host=158.160.49.223 fqdn=fhmlje668fenfo0guoj6.auto.internal
[databases]
main   ansible_host=158.160.36.154 fqdn=fhmc7djm5ksd0dg4k0n9.auto.internalreplica   ansible_host=158.160.35.129 fqdn=fhmd2tooar1tkm1c7op0.auto.internal
[storage]
storage   ansible_host=158.160.39.120 fqdn=fhm7q2sfgj2f5n07455a.auto.internal
```
Файл ansible.tf:
```hcl
resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/inventory.tftpl",
    { 
    webservers =  yandex_compute_instance.example,
    databases =  yandex_compute_instance.second, 
    storage =  [yandex_compute_instance.storage]   
   # fqdn =  
    }  
)

  filename = "${abspath(path.module)}/inventory"
}
```
![image](https://github.com/suntsovvv/ter-homeworks-03/assets/154943765/d31c2836-6512-4a2c-81d9-1ce9b68455f9)

### Задание 5*

```hcl
output "all_vms" {
  description = "Information about the instances"
  value = {
    web = [
      for instance in yandex_compute_instance.example : {
        name = instance.name
        id   = instance.id
        fqdn = instance.fqdn
      }
    ],

    db = [
          for instance in yandex_compute_instance.second : {
        name = instance.name
        id   = instance.id
        fqdn = instance.fqdn
        }
        ]
         
}
}
```
```
user@study:~/home_work/ter-homeworks/ter-homeworks-03/ter-homeworks-03$ terraform output
all_vms = {
  "db" = [
    {
      "fqdn" = "fhmc7djm5ksd0dg4k0n9.auto.internal"
      "id" = "fhmc7djm5ksd0dg4k0n9"
      "name" = "main"
    },
    {
      "fqdn" = "fhmd2tooar1tkm1c7op0.auto.internal"
      "id" = "fhmd2tooar1tkm1c7op0"
      "name" = "replica"
    },
  ]
  "web" = [
    {
      "fqdn" = "fhmjbrh67g7akcu7iql2.auto.internal"
      "id" = "fhmjbrh67g7akcu7iql2"
      "name" = "web-1"
    },
    {
      "fqdn" = "fhmlje668fenfo0guoj6.auto.internal"
      "id" = "fhmlje668fenfo0guoj6"
      "name" = "web-2"
    },
  ]
}
```
### Задание 6*    
1 -   
Файл ansible.tf:
```hcl
resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/inventory.tftpl",
    { 
    webservers =  yandex_compute_instance.example,
    databases =  yandex_compute_instance.second, 
    storage =  [yandex_compute_instance.storage]   
   # fqdn =  
    }  
)

  filename = "${abspath(path.module)}/inventory.cfg"
}


resource "random_password" "each" {
  for_each    = toset([for k, v in yandex_compute_instance.example : v.name ])
  length = 17
#> type(random_password.each) object(object)
}

resource "null_resource" "web_hosts_provision" {
#Ждем создания инстанса
depends_on = [yandex_compute_instance.storage, local_file.inventory_cfg]


#Костыль!!! Даем ВМ 60 сек на первый запуск. Лучше выполнить это через wait_for port 22 на стороне ansible
# В случае использования cloud-init может потребоваться еще больше времени
 provisioner "local-exec" {
    command = "sleep 60"
  }

#Запуск ansible-playbook
  provisioner "local-exec" {                  
   # command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/inventory.cfg ${abspath(path.module)}/test.yaml"
    command     = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg ${abspath(path.module)}/test.yaml --extra-vars '{\"secrets\": ${jsonencode( {for k,v in random_password.each: k=>v.result})} }'"
    on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
    #environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }
    triggers = {  
#всегда т.к. дата и время постоянно изменяются
      always_run         = "${timestamp()}" 
 # при изменении содержимого playbook файла
      playbook_src_hash  = file("${path.module}/test.yaml") 
      ssh_public_key     = var.public_key # при изменении переменной
    }

```
2 -   

