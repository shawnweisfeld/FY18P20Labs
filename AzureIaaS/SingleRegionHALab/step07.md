# Single Region High Availability Lab 
## Step 7 - Add the load balancer

So at this point you have 2 VMs, with each having its own public endpoint on the internet. However we want our users to be automatically routed to the right VM, and we dont want our VMs to have their own public endpoints. 

Lets start by creating a new public IP address that we will use for our load balancer. This will give our load balancer an endpoint on the internet. 

```
az network public-ip create --resource-group $RG --name myPublicIP
```

Great, now we can create the load balancer itself. When doing so we wire the load balancer up to the public IP address we created in the first step and declare a name for both the front end and the back end. The front end connects the load balancer to the world and the backend connects our VMs to the load balancer.  (This step will takes a few minutes to complete)

```
az network lb create --resource-group $RG --name myLoadBalancer --public-ip-address myPublicIP --frontend-ip-name myFrontEndPool --backend-pool-name myBackEndPool
```

Next we create a probe. The probe is what the load balancer uses to check if our back end VMs are healthy or not. If the load balancer detects that one of our VMs is sick, it will stop sending traffic to it. Since our VMs are web servers we are going to probe on port 80.

```
az network lb probe create --resource-group $RG --lb-name myLoadBalancer --name myHealthProbe --protocol tcp --port 80
```

Now we can create a rule, rules map incoming requests to our front end on a given port to a port on our back end VMs. Each request is routed to an Available VM in our backend pool in a, well balanced fashion. 

```
az network lb rule create --resource-group $RG --lb-name myLoadBalancer --name myLoadBalancerRuleWeb --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name myFrontEndPool --backend-pool-name myBackEndPool --probe-name myHealthProbe
```

While we want our web traffic to be distributed to the VMs in our backend in a balanced fashion, when I want to connect to a VM for maintenance through RDP, I want to ensure I connect to the VM I am looking for and not one at random. To enable that Azure Load Balancer supports Network Address Translation (NAT). Basically we can force a request on a specific port to always go to one of our back end VMs. Next lets setup RDP (port 3389 on the back end VMs) to 33891 for our first web server and 33892 for our second. 

```
az network lb inbound-nat-rule create --resource-group $RG --lb-name myLoadBalancer --name myLoadBalancerRuleRDP01 --protocol tcp --frontend-port 33891 --backend-port 3389 --frontend-ip-name myFrontEndPool

az network lb inbound-nat-rule create --resource-group $RG --lb-name myLoadBalancer --name myLoadBalancerRuleRDP02 --protocol tcp --frontend-port 33892 --backend-port 3389 --frontend-ip-name myFrontEndPool
```

Now we can create a new Network Security Group (NSG). This will control what traffic is allowed into our Azure Subnet. 

```
az network nsg create --resource-group $RG --name myNetworkSecurityGroup
```

Lets configure our network security group to allow in RDP traffic (port 3389)

```
az network nsg rule create --resource-group $RG --nsg-name myNetworkSecurityGroup --name myNetworkSecurityGroupRuleRDP --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  --destination-address-prefix '*' --destination-port-range 3389 --access allow --priority 1000
```

Now lets add a NSG rule to allow Web traffic through on Port 80

```
az network nsg rule create --resource-group $RG --nsg-name myNetworkSecurityGroup --name myNetworkSecurityGroupRuleHTTP --protocol tcp --direction inbound --priority 1001 --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range 80 --access allow --priority 2000
```

When we created our VMs earlier, it create 2 NSGs one applied to each NIC on each VM. Lets remove those NSGs from those NICs with the following commands. 

```
az network nic update --resource-group $RG --name Web01VMNic --remove "networkSecurityGroup"

az network nic update --resource-group $RG --name Web02VMNic --remove "networkSecurityGroup"
```

Since we want the same NSG applied to all of our Web Servers and all of our Web Servers live in the same subnet, we can apply the NSG on the subnet, and it will apply to any VMs in that subnet. 

```
az network vnet subnet update --resource-group $RG --name "web-subnet" --vnet-name "lab-vnet" --network-security-group myNetworkSecurityGroup
```

Now lets update the NIC on each one of our VMs, placing that NIC in the Backend Pool of the Load balancer and applying the NAT rule we defined earlier.  

```
az network nic ip-config update --resource-group $RG --name ipconfigWeb01 --nic-name Web01VMNic --lb-name MyLoadBalancer --lb-address-pools myBackEndPool --lb-inbound-nat-rules myLoadBalancerRuleRDP01

az network nic ip-config update --resource-group $RG --name ipconfigWeb02 --nic-name Web02VMNic --lb-name MyLoadBalancer --lb-address-pools myBackEndPool --lb-inbound-nat-rules myLoadBalancerRuleRDP02
```

Remember how earlier each of our VMs had its own public IP. Since we want all of our traffic to get routed through the load balancer, lets strip those public IPs from each of the VMs. 

```
az network nic ip-config update --resource-group $RG --name ipconfigWeb01 --nic-name Web01VMNic --remove "publicIpAddress"

az network nic ip-config update --resource-group $RG --name ipconfigWeb02 --nic-name Web02VMNic --remove "publicIpAddress"
```

Now, we can delete those extra public IP addresses.

```
az network public-ip delete --name Web01PublicIP --resource-group $RG

az network public-ip delete --name Web02PublicIP --resource-group $RG
```

And finally we can delete the NSGs assigned to each of the NICs since we have our new NSG at the subnet level.

```
az network nsg delete --name Web01NSG --resource-group $RG

az network nsg delete --name Web02NSG --resource-group $RG
```


## Lab Navigation
1. [Overview](./) 
1. [Connect to the Azure Cloud Shell](./step01.html)
1. [Select your subscription](./step02.html)
1. [Create the Resource Group](./step03.html)
1. [Create the Availability Set](./step04.html)
1. [Create the first vm](./step05.html)
1. [Create the second VM same as the first](./step06.html)
1. [Add the load balancer](./step07.html) *<-- you are here*
1. [Look Mom its magic](./step08.html)
1. [Extending this lab and Cleanup](./step09.html)
1. [CLI commands Summary](./summary.html)

[Back to All Labs](../../index.html)