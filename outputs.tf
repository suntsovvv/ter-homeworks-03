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