# Single Region High Availability Lab

![Drawing](/SingleRegion/multi-vm-diagram.png)

## In this lab we will:
1. Deploy two Windows VMs and install IIS on each
1. The VMs will be placed in an [Availability Set](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/manage-availability) to be in scope for the [99.95% VM SLA](https://azure.microsoft.com/en-us/support/legal/sla/virtual-machines)
1. Each VMs will use [Managed Storage](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview) 
1. An Azure Internet Facing [Load balancer](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-internet-overview) will be used to distribute web traffic between the VMs
1. VMs will be placed inside a [Virtual Network/Subnet](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) with appropriate [Network Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-nsg) to limit traffic. 

This lab is based on the following article: [Run load-balanced VMs for scalability and availability](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/virtual-machines-windows/multi-vm). NOTE: at the time of writing this lab the ARM template at the bottom of the article is broken.

## The Lab
### 1) Connect to the Azure Cloud Shell
In this lab we will be using the [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview). This provides us the ability to use the Azure CLI 2.0 from within our browser without needing to install anything locally (PowerShell support coming soon). You can also use the Azure CLI 2.0 from the console on your computer ([More Info](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)). Additionally everything we are doing can also be done via the Portal, PowerShell or an ARM Template, however we will be focusing on the Azure CLI 2.0 commands in this lab.  

Lets begin by logging into the [Azure Portal](https://portal.azure.com). Once you are in, select the icon to launch the Cloud Shell in the upper right.

![Icon](/SingleRegion/shell-icon.png)

You will now see a console at the bottom of your browser window. Here you will enter the commands below to complete the lab. 

Let's start by asking for some help from the Azure CLI 2.0. Enter the following command at the promt and observe the output. 

```
az -h
```

As you see adding the `-h` switch to the end of any Azure CLI 2.0 command will output the help file for that command. Lets investigate help a bit more, try the following command.

```
az vm -h
```

As you can see `vm` is a subgroup fo the `az` command, by combining them together with the `-h` switch we can find out all the things we can do with VMs in the CLI. 

### 2) Select your subscription

Now that we know how to ask for help, lets run the following command to list the available Azure Subscriptions tied to your account. 

```
az account list --output table
``` 

> Note: you can copy paste commands from here into the portal, however you must use the mouse when pasting into the portal. 

Your output should look something like this:

![Screen](/SingleRegion/accounts.png)

Take note of the `--output table` switch. This takes the output from the `list` command and formats it in an easy to read table. 

You can see that I have 3 Azure subscriptions. You might only have one, however if you have more than one ensure that the one you want to use for the lab today is set as default. If the proper subscription is not set to default you can change it with this command.

```
az account set --subscription 'Subscription Name'
```

It is also a good idea to take a look at the Azure Regions available to your subscription, we will be using one of these regions for our lab today.

```
az account list-locations --output table
```

When picking a region I look at a few factors for example: Does the region have the Azure services I need ([check the list here](https://azure.microsoft.com/en-us/regions/services/))? Is the region close to me and in the right geo-political area? For todays lab you can use just about any Azure region as the IaaS services we are going to use are available in most regions. 

### 3) Create the Resource Group
A resource group is a container that holds related resources for an Azure solution. The resource group can include all the resources for the solution, or only those resources that you want to manage as a group. You decide how you want to allocate resources to resource groups based on what makes the most sense for your organization and workload. [See Resource groups](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#resource-groups). For todays exercise we are going to place everything into one resource group, this will make cleaning up at the end of the lab simple. 

Before we create our resource group, lets first declare 2 variables to hold the name of our resource group and the region we will be using today. Execute the following two commands:

```
RG="SingleRegionHA-rg"

REGION="westus2"
```

> NOTE: if you loose your connection to the Azure Cloud Shell you might need to redefine your variables.

Now we can create the resource group.

```
az group create --location $REGION --name $RG
```

After you run this command you will see a response from Azure in json providing details about the resource group you just created. However one of the nice things about the CLI being in the portal is that it is easy to view resources as you create/modify/delete them, all in the same window. For example lets click on "Resource Groups" in the Portal Navigation bar. This should pull up the list of all your Resource Groups, here you can select the one that we just created. 

![Resource Groups](/SingleRegion/resource-groups.png)

> NOTE: Remember, everything we are creating via the CLI can also be created using the Portal, PowerShell commands or an ARM template. Many users will start with the Portal when they are learning, and then migrate to the CLI, PowerShell or an ARM template as their skills and processes mature. 

### 4) Create the Availability Set
An Availability Set is our way of telling Azure what a tier of our application looks like. For example a traditional 3 tier application will consist of a Web Tier (filled with web servers), an Application Tier (filled with application servers), and a Database Tier (you guessed it, filled with database servers). Each of the servers inside a given tier of our applications will be configured the same. This allows us to load balance traffic between the servers, and if one of our servers in an Availability Set gets sick, we can route traffic to the others. 

Azure goes the extra step and ensures that VMs in the same Availability Set don't share physical components. Reducing the chance that a single physical outage (VM Host machine, top of rack network switch, etc.) can impact all the VMs in a given Availability Set. Additionally, if we are using Managed Storage, Azure will ensure that the Disks that our VMs rely on are on different storage devices, reducing the chance that a storage device failure will impact all of the VMs in our Availability Set. 

```
az vm availability-set create --name "web-as" --resource-group $RG --location $REGION
```

After you run the command, press the refesh button and look at what you did.

![Portal Refresh](/SingleRegion/portal-refresh.png)

Also try and click on the name of the availability set, and take a look at the overview tab. Here you will see that the Availability set we created has 2 Fault Domains and 5 Update Domains. Each VM we deploy will be deployed into a Fault Domain and Update Domain. Fault domains ensure the physical isolation we were talking about earlier. Update domains are used for planned maintenance. 

![Fault and Update Domains](/SingleRegion/fault-update-domains.png)

> For the rest of the lab today I encourage you to pull up the resources we are going to create via the CLI in the portal and take a look at the options you have available to you. I am not going to include screen shots of each interesting setting. 

### 5) Create the first vm

Start by executing the command to create the VM itself. (This step will takes a few minutes to complete)

```
az vm create --name "Web01" --image "Win2016Datacenter" --resource-group $RG --availability-set "web-as" --location $REGION --size Standard_DS1_v2 --vnet-name "lab-vnet" --subnet "web-subnet" --admin-username "headgeek" --admin-password "AzureRocks2020("
```

>Note: if you tripple click on the line above it will select the entire line, so you can copy and paste into the CLI.

This command created a bunch of resources for us (in the same order you should see them in the portal):
1. a virtual network (VNET) and subnet for our VM to live in
1. the VM itself
1. a managed SSD Disk so that our VM has a place for its operating system
1. a Network Security Group (NSG) allowing folks from the internet to get to our VM via Remote Desktop (RDP)
1. a public ip address so that we can locate our VM on the internet
1. a Network Interface Card (NIC) so our VM can talk to the network

Now that we have a VM we need to install IIS and deploy our website. Here we can use the Azure Desired State Configuration VM Extension to install IIS inside the VM and download a Simple Website into the VM.  (This step will takes a few minutes to complete)

```
az vm extension set --name DSC --publisher Microsoft.Powershell --version 2.19 --vm-name "Web01" --resource-group $RG --settings '{"ModulesURL":"https://raw.githubusercontent.com/shawnweisfeld/IaaS-High-Availability-Lab/master/WebServerSetup.zip", "configurationFunction": "WebServer01Setup.ps1\\WebServer" }'
```

Next, lets open up port 80 to allow web traffic

```
az vm open-port --port 80 --resource-group $RG --name "Web01"
```

At this time we have a running web application deployed to a single VM we have exposed to the internet. Lets take a look at it in our browser. To do so we will need the IP address of the VM. We can get that IP with the following command:

```
az vm list-ip-addresses --name Web01 --resource-group $RG --output table
```

Using the Public IP address from the prior step, open your web browser and navigate to your new website. You should see a blue website, with Web 01 written in the top left. 

### 6) Create the second VM same as the first

Start by executing the following command to create the VM itself. Since we created the Virtual Network and Subnet for our VM to live in in the last step, this command will add this vm to the existing one.  (This step will takes a few minutes to complete)

```
az vm create --name "Web02" --image "Win2016Datacenter" --resource-group $RG --availability-set "web-as" --location $REGION --size Standard_DS1_v2 --vnet-name "lab-vnet" --subnet "web-subnet" --admin-username "headgeek" --admin-password "AzureRocks2020("
```

Now, like we did before, use the Azure Desired State Configuration Extension to install IIS and deploy our Simple Website  (This step will takes a few minutes to complete)

```
az vm extension set --name DSC --publisher Microsoft.Powershell --version 2.19 --vm-name "Web02" --resource-group $RG --settings '{"ModulesURL":"https://raw.githubusercontent.com/shawnweisfeld/IaaS-High-Availability-Lab/master/WebServerSetup.zip", "configurationFunction": "WebServer02Setup.ps1\\WebServer"}'
```

And lets open up port 80 to allow web traffic directly to the host

```
az vm open-port --port 80 --resource-group $RG --name "Web02"
```

Now lets get the public IP assigned to the VM.

```
az vm list-ip-addresses --name Web02 --resource-group $RG --output table
```

Using the IP address from the prior step, open your web browser and navigate to your new website. You should see a green site with Web 02 in the upper left. In the real world you would want both web servers to look exactly alike, however for this lab, I have made them look difference so we can tell them apart. 

### 7) Add the load balancer

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

### 8) 'Look Mom its magic'

Lets take a look at our handy work. Lets get a list of all the public-ips we have left (should only be one assigned to our load balancer). Once you get the IP, put it into a new browser window, and watch it refresh a bunch of times. 

```
az network public-ip list --resource-group $RG --output table
```

What you will see will vary based on if your browser is creating a new transport session on each refresh. For example, try opening the link with an "in-private" instance of Edge, do you notice a different behavior? 

More information on the way the load balancer distributes traffic can be found [here](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-distribution-mode).

So what happens if a VM gets sick. We can replicate that by turning one of our VMs off with the following command. Turn off the VM corresponding to the page you see in your browser.

```
az vm stop --resource-group $RG --name Web01

 -- OR --

az vm stop --resource-group $RG --name Web02
```

After the VM is stopped, you should see all the requests serviced by the other vm. 

You might get a "Server Unavalable" error message, this happens because it takes a moment for the Load Balancer to sense that the VM was turned off, and stop routing traffic to it. If this happens just manually press the refresh button in your browser. 

Now lets restart the VM you stopped.

```
az vm start --resource-group $RG --name Web01

 -- OR --

az vm start --resource-group $RG --name Web02
```

Again, refresh your website, and you will start seeing responses from both VMs. NOTE: it can take a minute or so for the Load balancer to mark the VM you rebooted as healthy again and start routing traffic to it, and you might have to close and reopen your browser to force it to restart the transport session, even with edge in-private. 

### 9) Next steps
Want to have some more fun, how about:
1. creating this using Linux VMs and NGINX instead of Windows and IIS
1. deploying this to a second region and load balancing between the two regions with Traffic Manager
1. writing a custom probe for the load balancer that checks the helth of other dependent resources
1. deploy a database tier using SQL Server Availability Groups

### 10) Clean up

To clean up, just delete the entire Resource Group

```
az group delete --name $RG --yes --no-wait
```

Note the use of the `--no-wait` argument, this will start the deletion and let it run in the background so we don't have to wait for it to complete. 

### Summary of CLI commands by section
#### 1) Connect to the Azure Cloud Shell
```
az -h

az vm -h
```

#### 2) Select your subscription
```
az account list --output table

az account set --subscription 'Subscription Name'

az account list-locations --output table
```

#### 3) Create the Resource Group
```
RG="SingleRegionHA-rg"

REGION="westus2"

az group create --location $REGION --name $RG
```

#### 4) Create the Availability Set
```
az vm availability-set create --name "web-as" --resource-group $RG --location $REGION
```

#### 5) Create the first vm
```
az vm create --name "Web01" --image "Win2016Datacenter" --resource-group $RG --availability-set "web-as" --location $REGION --size Standard_DS1_v2 --vnet-name "lab-vnet" --subnet "web-subnet" --admin-username "headgeek" --admin-password "AzureRocks2020("

az vm extension set --name DSC --publisher Microsoft.Powershell --version 2.19 --vm-name "Web01" --resource-group $RG --settings '{"ModulesURL":"https://raw.githubusercontent.com/shawnweisfeld/IaaS-High-Availability-Lab/master/WebServerSetup.zip", "configurationFunction": "WebServer01Setup.ps1\\WebServer" }'

az vm open-port --port 80 --resource-group $RG --name "Web01"

az vm list-ip-addresses --name Web01 --resource-group $RG --output table
```

#### 6) Create the second VM same as the first
```
az vm create --name "Web02" --image "Win2016Datacenter" --resource-group $RG --availability-set "web-as" --location $REGION --size Standard_DS1_v2 --vnet-name "lab-vnet" --subnet "web-subnet" --admin-username "headgeek" --admin-password "AzureRocks2020("

az vm extension set --name DSC --publisher Microsoft.Powershell --version 2.19 --vm-name "Web02" --resource-group $RG --settings '{"ModulesURL":"https://raw.githubusercontent.com/shawnweisfeld/IaaS-High-Availability-Lab/master/WebServerSetup.zip", "configurationFunction": "WebServer02Setup.ps1\\WebServer"}'

az vm open-port --port 80 --resource-group $RG --name "Web02"

az vm list-ip-addresses --name Web02 --resource-group $RG --output table
```

#### 7) Add the load balancer
```
az network public-ip create --resource-group $RG --name myPublicIP

az network lb create --resource-group $RG --name myLoadBalancer --public-ip-address myPublicIP --frontend-ip-name myFrontEndPool --backend-pool-name myBackEndPool

az network lb probe create --resource-group $RG --lb-name myLoadBalancer --name myHealthProbe --protocol tcp --port 80

az network lb rule create --resource-group $RG --lb-name myLoadBalancer --name myLoadBalancerRuleWeb --protocol tcp --frontend-port 80 --backend-port 80 --frontend-ip-name myFrontEndPool --backend-pool-name myBackEndPool --probe-name myHealthProbe

az network lb inbound-nat-rule create --resource-group $RG --lb-name myLoadBalancer --name myLoadBalancerRuleRDP01 --protocol tcp --frontend-port 33891 --backend-port 3389 --frontend-ip-name myFrontEndPool

az network lb inbound-nat-rule create --resource-group $RG --lb-name myLoadBalancer --name myLoadBalancerRuleRDP02 --protocol tcp --frontend-port 33892 --backend-port 3389 --frontend-ip-name myFrontEndPool

az network nsg create --resource-group $RG --name myNetworkSecurityGroup

az network nsg rule create --resource-group $RG --nsg-name myNetworkSecurityGroup --name myNetworkSecurityGroupRuleRDP --protocol tcp --direction inbound --source-address-prefix '*' --source-port-range '*'  --destination-address-prefix '*' --destination-port-range 3389 --access allow --priority 1000

az network nsg rule create --resource-group $RG --nsg-name myNetworkSecurityGroup --name myNetworkSecurityGroupRuleHTTP --protocol tcp --direction inbound --priority 1001 --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range 80 --access allow --priority 2000

az network nic update --resource-group $RG --name Web01VMNic --remove "networkSecurityGroup"

az network nic update --resource-group $RG --name Web02VMNic --remove "networkSecurityGroup"

az network vnet subnet update --resource-group $RG --name "web-subnet" --vnet-name "lab-vnet" --network-security-group myNetworkSecurityGroup

az network nic ip-config update --resource-group $RG --name ipconfigWeb01 --nic-name Web01VMNic --lb-name MyLoadBalancer --lb-address-pools myBackEndPool --lb-inbound-nat-rules myLoadBalancerRuleRDP01

az network nic ip-config update --resource-group $RG --name ipconfigWeb02 --nic-name Web02VMNic --lb-name MyLoadBalancer --lb-address-pools myBackEndPool --lb-inbound-nat-rules myLoadBalancerRuleRDP02

az network nic ip-config update --resource-group $RG --name ipconfigWeb01 --nic-name Web01VMNic --remove "publicIpAddress"

az network nic ip-config update --resource-group $RG --name ipconfigWeb02 --nic-name Web02VMNic --remove "publicIpAddress"

az network public-ip delete --name Web01PublicIP --resource-group $RG

az network public-ip delete --name Web02PublicIP --resource-group $RG

az network nsg delete --name Web01NSG --resource-group $RG

az network nsg delete --name Web02NSG --resource-group $RG
```

#### 8) 'Look Mom its magic'
```
az network public-ip list --resource-group $RG --output table

az vm stop --resource-group $RG --name Web01
 -- OR --
az vm stop --resource-group $RG --name Web02

az vm start --resource-group $RG --name Web01
 -- OR --
az vm start --resource-group $RG --name Web02
```
#### 9) Next steps

#### 10) Clean up
```
az group delete --name $RG --yes --no-wait
```
