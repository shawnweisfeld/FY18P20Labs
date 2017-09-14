# Single Region High Availability Lab 
## Step 5 - Create the first vm

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


## Lab Navigation
1. [Overview](./) 
1. [Connect to the Azure Cloud Shell](./step01.html)
1. [Select your subscription](./step02.html)
1. [Create the Resource Group](./step03.html)
1. [Create the Availability Set](./step04.html)
1. [Create the first vm](./step05.html) *<-- you are here*
1. [Create the second VM same as the first](./step06.html)
1. [Add the load balancer](./step07.html)
1. [Look Mom its magic](./step08.html)
1. [Extending this lab and Cleanup](./step09.html)
1. [CLI commands Summary](./summary.html)