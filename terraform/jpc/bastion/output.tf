output "public_ips" {
  value = [ "${ triton_machine.bastion.*.primaryip }" ]
}
