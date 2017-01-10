provider "triton" {
  account      = "${ var.account }"
  key_id       = "${ var.key_id }"
  key_material = "${ file(var.key_path) }"
  url          = "https://us-sw-1.api.joyent.com"
}

module "bastion" {
    source = "./bastion"
    name = "kubernetes"
    ubuntu_container_image = "${ var.ubuntu_container_image }"
    container_package = "${ var.container_package }"
    network = "${ var.network }"
    public_network = "${ var.public_network }"
    key_material = "${ file(var.key_path) }"
}

module "controllers" {
    source = "./private"
    name = "controller"
    user = "root"
    count = 3
    image = "${ var.ubuntu_container_image }"
    package = "${ var.container_package }"
    network = "${ var.network }"
    bastion_host = "${ module.bastion.public_ips[0] }"
    key_material = "${ file(var.key_path) }"
    command = "/bin/true"
}

module "workers" {
    source = "./private"
    name = "worker"
    user = "ubuntu"
    count = 3
    image = "${ var.ubuntu_kvm_image }"
    package = "${ var.kvm_package }"
    network = "${ var.network }"
    bastion_host = "${ module.bastion.public_ips[0] }"
    key_material = "${ file(var.key_path) }"
    command = "/usr/bin/sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/"
}
