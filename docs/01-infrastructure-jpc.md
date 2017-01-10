# Cloud Infrastructure Provisioning - Joyent Public Cloud

This lab will walk you through provisioning the compute instances required for running a H/A Kubernetes cluster. A total of 6 virtual machines will be created.

After completing this guide you should have the following compute instances:

```
triton ls
```

````
SHORTID   NAME         IMG                              STATE    FLAGS  AGE
e2a3b8a6  kubernetes   ubuntu-16.04@20161213            running  -      1d
b080b2c4  controller0  ubuntu-16.04@20161213            running  -      1d
846d3bb7  controller1  ubuntu-16.04@20161213            running  -      1d
e3226afb  controller2  ubuntu-16.04@20161213            running  -      1d
753c5f0c  worker0      ubuntu-certified-16.04@20161221  running  K      1d
7bb2a272  worker1      ubuntu-certified-16.04@20161221  running  K      1d
c34597cf  worker2      ubuntu-certified-16.04@20161221  running  K      1d
````

To make our Kubernetes control plane remotely accessible, a public IP address will be provisioned and assigned to `kubernetes` running haproxy that will sit in front of the 3 Kubernetes controllers.

## Authentication

Create a profile

```
$ triton profile create
A profile name. A short string to identify a CloudAPI endpoint to the
`triton` CLI.
name: us-sw-1

The CloudAPI endpoint URL.
url: https://us-sw-1.api.joyent.com

Your account login name.
account: demo

The fingerprint of the SSH key you have registered for your account.
Alternatively, You may enter a local path to a public or private SSH key to
have the fingerprint calculated for you.
keyId: SHA256:llvktHdAL7o1lfiQFWKgAOzAYN1YBiIYH89TZ4UbDi8

Saved profile "us-sw-1".
```

## Networking

Create a Kubernetes network and subnet through the GUI interface https://my.joyent.com/main/#!/network/networks/create

```
Name: kubernetes
Data Center: us-sw-1
Subnet: 10.240.0.0/24
Gateway: 10.240.0.1
IP Range: 10.240.0.2 10.240.0.254
VLAN: (Leave at the default)
DNS Resolvers: 8.8.8.8 8.8.4.4
Routes: <left blank>
Description: Kubernetes Private Network
Provision NAT zone on the gateway address: <checked>
```

### TODO: Firewall Rules

## Provision Virtual Machines

All the VMs in this lab will be provisioned using Ubuntu 16.04 mainly because it runs a newish Linux Kernel that has good support for Docker.

### Virtual Machines

#### Load Balancer/Bastion

```
triton instance create \
 --wait \
 --name=kubernetes \
 -N Joyent-SDC-Public,kubernetes \
 -m user-data="hostname=kubernetes" \
 ubuntu-16.04 g4-highcpu-1G
```

#### Kubernetes Controllers

```
triton instance create \
 --wait \
 --name=controller0 \
 -N kubernetes \
 -m user-data="hostname=controller0" \
 ubuntu-16.04 g4-highcpu-1G
```

```
triton instance create \
 --wait \
 --name=controller1 \
 -N kubernetes \
 -m user-data="hostname=controller1" \
 ubuntu-16.04 g4-highcpu-1G
```

```
triton instance create \
 --wait \
 --name=controller2 \
 -N kubernetes \
 -m user-data="hostname=controller2" \
 ubuntu-16.04 g4-highcpu-1G
```

#### Kubernetes Worker Agent

```
triton instance create \
 --wait \
 --name=worker0 \
 -N kubernetes \
 -m user-data="hostname=worker0" \
 ubuntu-certified-16.04 k4-highcpu-kvm-1.75G
```

```
triton instance create \
 --wait \
 --name=worker1 \
 -N kubernetes \
 -m user-data="hostname=worker0" \
 ubuntu-certified-16.04 k4-highcpu-kvm-1.75G
```

```
triton instance create \
 --wait \
 --name=worker2 \
 -N kubernetes \
 -m user-data="hostname=worker0" \
 ubuntu-certified-16.04 k4-highcpu-kvm-1.75G
```

Allow root login to certified image

```
BASTION=$(triton ip kubernetes)
IP=$(triton instance list -o 'ips' -j name=worker0 | sed 's/.*ips":."\([0-9.]\+\)".*/\1/')
ssh -o proxycommand="ssh root@$BASTION -W %h:%p" ubuntu@$IP sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/
IP=$(triton instance list -o 'ips' -j name=worker1 | sed 's/.*ips":."\([0-9.]\+\)".*/\1/')
ssh -o proxycommand="ssh root@$BASTION -W %h:%p" ubuntu@$IP sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/
IP=$(triton instance list -o 'ips' -j name=worker2 | sed 's/.*ips":."\([0-9.]\+\)".*/\1/')
ssh -o proxycommand="ssh root@$BASTION -W %h:%p" ubuntu@$IP sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/
```
