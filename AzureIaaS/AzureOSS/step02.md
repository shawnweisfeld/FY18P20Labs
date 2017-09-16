# Open Source Workloads in Azure with Linux
## Create a Linux VM

1. Lets start by defining two variables to hold the name of our resource group and the Azure region that we want it to live in.
    ```
    RG="osslab-rg"
    
    REGION="westus2"
    ```
1. Now lets create a resource group, using the variables we defined in the last step
    ```
    az group create --location $REGION --name $RG
    ```
1. Now using an ARM template, lets deploy a VM into the resource group we just created
    ```
    
    ```