# Open Source Workloads in Azure with Linux
## Create a Linux VM in Azure

1. Lets start by defining two variables to hold the name of our resource group and the Azure region that we want it to live in.
    ```
    RG="osslab-rg"
    
    REGION="westus2"
    ```
1. Now lets create a resource group, using the variables we defined in the last step
    ```
    az group create --location $REGION --name $RG
    ```
1. Now using an ARM template, lets deploy a VM into the resource group we just created.
    ```
    az group deployment create -g $RG --template-uri https://raw.githubusercontent.com/shawnweisfeld/FY18P20Labs/master/AzureIaaS/AzureOSS/assets/azuredeploy.json
    ```
    You will be prompted to provide: (NOTE: everything should be lowercase)

    1. Your admin user name (i.e. `shawn`), not `admin`
    1. A DNS Custom Name (two random characters)
    1. Your SSH key, we created this earlier. Remember it should start with `ssh-rsa` and end with your email address
    1. The name of the VM, use `myosslabvm`

1. After a few minutes you should see some JSON in the shell, these are the details about the VM you just provisioned.
    
    > While you are waiting take read through the ARM template to get an idea of what you are building. You can see the template [here](https://github.com/shawnweisfeld/FY18P20Labs/blob/master/AzureIaaS/AzureOSS/assets/azuredeploy.json).


## Lab Navigation
1. [Overview](./)
1. [Setup your environment](./step01.html)
1. [Create a Linux VM in Azure](./step02.html) *<-- you are here*
1. [Connect to a Linux VM in Azure](./step03.html)
1. [Install components to make our VM a Web Server](./step04.html)
1. [Cleanup](./step05.html)

[Back to Index](../../index.html)        