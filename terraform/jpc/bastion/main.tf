variable "name" {}
variable "ubuntu_container_image" {}
variable "container_package" {}
variable "network" {}
variable "public_network" {}
variable "key_material" {}

resource "triton_machine" "bastion" {
    name = "${ var.name }"
    image = "${ var.ubuntu_container_image }"
    package = "${ var.container_package }"

    nic {
        network = "${ var.public_network }"
    }

    nic {
        network = "${ var.network }"
    }

    tags {
        role = "bastion"
    }

    user_data = "hostname=${ var.name }"

    connection {
        host = "${ self.ips[0] }"
        user = "root"
        private_key = "${ var.key_material }"
    }

    provisioner "remote-exec" {
        inline = ["/bin/true"]
    }
}
