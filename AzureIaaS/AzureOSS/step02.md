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
    az group deployment create -g $RG --template-uri https://raw.githubusercontent.com/shawnweisfeld/FY18P20Labs/master/AzureIaaS/AzureOSS/assets/azuredeploy.json
    ```
    1. You will be prompted to provide: 
        1. Your admin user name (i.e. `shawn`)
        1. A DNS Custom Name (two random lowercase characters)
        1. Your SSH key, we created this earlier. Remember it should start with `ssh-rsa` and end with your email address
        1. The name you want to use for your VM (i.e. `myosslabvm`)
    1. 
    