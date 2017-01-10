variable "name" {}
variable "user" {}
variable "count" {}
variable "image" {}
variable "package" {}
variable "network" {}
variable "bastion_host" {}
variable "key_material" {}
variable "command" {}


resource "triton_machine" "private_resource" {
    count = "${ var.count }"
    name = "${ format("%s%d", var.name, count.index) }"
    image = "${ var.image }"
    package = "${ var.package }"
    nic { network = "${ var.network }" }
    user_data = "${ format("hostname=%s%d", var.name, count.index) }"

    connection {
        host = "${ self.ips[0] }"
        user = "${ var.user }"
        private_key = "${ var.key_material }"
        bastion_host = "${ var.bastion_host }"
        bastion_user = "root"
    }

    provisioner "remote-exec" {
        inline = ["${ var.command }"]
    }
}
