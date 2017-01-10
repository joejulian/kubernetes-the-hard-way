# Managing the Container Network Routes and Overlay Network

Now that each worker node is online we need to add an overlay network and routes to make sure that Pods running on different machines can talk to each other.

These instructions require kubectl on the workers. Please follow [these instructions](06-kubectl.md) to install kubectl on each worker.

## Container Subnets

The IP addresses for each pod will be allocated from the `podCIDR` range assigned to each Kubernetes worker through the node registration process.

The `podCIDR` will be allocated from the cluster cidr range as configured on the Kubernetes Controller Manager with the following flag:

```
--cluster-cidr=10.200.0.0/16
```

Based on the above configuration each node will receive a `/24` subnet. For example:

```
10.200.0.0/24
10.200.1.0/24
10.200.2.0/24
...
``` 

## Populate the Routing Table

Populate the routing table with the l3 routes over our overlay network.

Use `kubectl` to print the `InternalIP` and `podCIDR` for each worker node:

```
kubectl get nodes \
  --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address} {.spec.podCIDR} {"\n"}{end}'
```

Output:

```
10.240.0.20 10.200.0.0/24 
10.240.0.21 10.200.1.0/24 
10.240.0.22 10.200.2.0/24 
```

## Create an overlay network

JPC does not do multicasting so we need to creae a unicast vxlan overlay. We will create it in such a way that it logically matches the podCIDR network.

> Do this on each worker:

```
INTERNAL_IP=$(ip addr show net0 | awk '/inet /{gsub(/\/[0-9][0-9]/,"");print $2}')
VXLAN_IP=$(kubectl get nodes \
  --output=jsonpath='{range .items[*]} {.status.addresses[?(@.type=="InternalIP")].address} {.spec.podCIDR} {"\n"}{end}' | 
  awk "/$INTERNAL_IP/{print \$2}" | 
  sed -e 's/10\.200\./172.16./' -e 's@0/@1/@')
ip link add vxlan0 type vxlan id 1 dstport 0
eval $(kubectl get nodes \
  --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}' |
  grep -v $INTERNAL_IP |
  awk '{ print "bridge fdb append to 00:00:00:00:00:00 dst " $1 " via net0" }')
ip addr add $VXLAN_IP dev vxlan0
ip link set up vxlan0
```

## Create Routes

> Do this on each worker:

```
eval $(kubectl get nodes \
  --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address} {.spec.podCIDR} {"\n"}{end}' | 
  grep -v $INTERNAL_IP | 
  awk '{GW=$2;gsub("10.200","172.16",GW); gsub("0/24","1",GW); print "ip route add " $2 " via " GW }')
```

