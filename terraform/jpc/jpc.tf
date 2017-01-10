variable "ubuntu_kvm_image" {
    type = "string"
    description = "Ubuntu 16.04.1 LTS (20161221 64-bit). Certified Ubuntu Server Cloud Image from Canonical."
    default = "698a8146-d6d9-4352-99fe-6557ebce5661"
}

variable "ubuntu_container_image" {
    type = "string"
    description = "Container-native Ubuntu 16.04 64-bit image. Built to run on containers with bare metal speed, while offering all the services of a typical unix host."
    default = "8879c758-c0da-11e6-9e4b-93e32a67e805"
}

variable "kvm_package" {
    type = "string"
    description = "Compute Optimized KVM 1.75G RAM - 1 vCPU - 50 GB Disk (k4-highcpu-kvm-1.75G)"
    default = "14b5edc4-d0f8-11e5-b4d2-b3e6e8c05f9d"
}

variable "container_package" {
    type = "string"
    description = "Compute Optimized 1G RAM - 0.5 vCPU - 25 GB Disk (g4-highcpu-1G)"
    default = "14af2214-d0f8-11e5-9399-77e0d621f66d"
}

variable "public_network" {
    type = "string"
    description = "Joyent-SDC-Public"
    default = "f7ed95d3-faaf-43ef-9346-15644403b963"
}
