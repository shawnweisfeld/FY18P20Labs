# Single Region High Availability Lab 
## Summary of CLI commands by section
### 1) Connect to the Azure Cloud Shell
```
az -h

az vm -h
```

### 2) Select your subscription
```
az account list --output table

az account set --subscription 'Subscription Name'

az account list-locations --output table
```

### 3) Create the Resource Group
```
RG="SingleRegionHA-rg"

REGION="westus2"

az group create --location $REGION --name $RG
```

### 4) Create the Availability Set
```
az vm availability-set create --name "web-as" --resource-group $RG --location $REGION
```

### 5) Create the first vm
```
az vm create --name "Web01" --image "Win2016Datacenter" --resource-group $RG --availability-set "web-as" --location $REGION --size Standard_DS1_v2 --vnet-name "lab-vnet" --subnet "web-subnet" --admin-username "headgeek" --admin-password "AzureRocks2020("

az vm extension set --name DSC --publisher Microsoft.Powershell --version 2.19 --vm-name "Web01" --resource-group $RG --settings '{"ModulesURL":"https://github.com/shawnweisfeld/FY18P20Labs/blob/master/AzureIaaS/SingleRegionHALab/assets/WebServerSetup.zip?raw=true", "configurationFunction": "WebServer01Setup.ps1\\WebServer" }'

az vm open-port --port 80 --resource-group $RG --name "Web01"

az vm list-ip-addresses --name Web01 --resource-group $RG --output table
```

### 6) Create the second VM same as the first
```
az vm create --name "Web02" --image "Win2016Datacenter" --resource-group $RG --availability-set "web-as" --location $REGION --size Standard_DS1_v2 --vnet-name "lab-vnet" --subnet "web-subnet" --admin-username "headgeek" --admin-password "AzureRocks2020("

az vm extension set --name DSC --publisher Microsoft.Powershell --version 2.19 --vm-name "Web02" --resource-group $RG --settings '{"ModulesURL":"https://github.com/shawnweisfeld/FY18P20Labs/blob/master/AzureIaaS/SingleRegionHALab/assets/WebServerSetup.zip?raw=true", "configurationFunction": "WebServer02Setup.ps1\\WebServer" }'

az vm open-port --port 80 --resource-group $RG --name "Web02"

az vm list-ip-addresses --name Web02 --resource-group $RG --output table
```

### 7) Add the load balancer
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

### 8) 'Look Mom its magic'
```
az network public-ip list --resource-group $RG --output table

az vm stop --resource-group $RG --name Web01
 -- OR --
az vm stop --resource-group $RG --name Web02

az vm start --resource-group $RG --name Web01
 -- OR --
az vm start --resource-group $RG --name Web02
```
### 9) Extending this lab and Cleanup

```
az group delete --name $RG --yes --no-wait
```


## Lab Navigation
1. [Overview](./)
1. [Connect to the Azure Cloud Shell](./step01.html)
1. [Select your subscription](./step02.html)
1. [Create the Resource Group](./step03.html)
1. [Create the Availability Set](./step04.html)
1. [Create the first vm](./step05.html)
1. [Create the second VM same as the first](./step06.html)
1. [Add the load balancer](./step07.html)
1. [Look Mom its magic](./step08.html)
1. [Extending this lab and Cleanup](./step09.html)
1. [CLI commands Summary](./summary.html) *<-- you are here*