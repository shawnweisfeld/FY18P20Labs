# Single Region High Availability Lab 
## Step 6 - Create the second VM same as the first

Start by executing the following command to create the VM itself. Since we created the Virtual Network and Subnet for our VM to live in in the last step, this command will add this vm to the existing one.  (This step will takes a few minutes to complete)

```
az vm create --name "Web02" --image "Win2016Datacenter" --resource-group $RG --availability-set "web-as" --location $REGION --size Standard_DS1_v2 --vnet-name "lab-vnet" --subnet "web-subnet" --admin-username "headgeek" --admin-password "AzureRocks2020("
```

Now, like we did before, use the Azure Desired State Configuration Extension to install IIS and deploy our Simple Website  (This step will takes a few minutes to complete)

```
az vm extension set --name DSC --publisher Microsoft.Powershell --version 2.19 --vm-name "Web02" --resource-group $RG --settings '{"ModulesURL":"https://github.com/shawnweisfeld/FY18P20Labs/blob/master/AzureIaaS/SingleRegionHALab/assets/WebServerSetup.zip?raw=true", "configurationFunction": "WebServer02Setup.ps1\\WebServer" }'
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

## Lab Navigation
1. [Overview](./) 
1. [Connect to the Azure Cloud Shell](./step01.html)
1. [Select your subscription](./step02.html)
1. [Create the Resource Group](./step03.html)
1. [Create the Availability Set](./step04.html)
1. [Create the first vm](./step05.html)
1. [Create the second VM same as the first](./step06.html) *<-- you are here*
1. [Add the load balancer](./step07.html)
1. [Look Mom its magic](./step08.html)
1. [Extending this lab and Cleanup](./step09.html)
1. [CLI commands Summary](./summary.html)

[Back to Index](../../index.html)