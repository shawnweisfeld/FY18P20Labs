# Single Region High Availability Lab 
## Step 9 - Extending this lab and Cleanup

### Extending this lab
Want to have some more fun, how about:
1. creating this using Linux VMs and NGINX instead of Windows and IIS
1. deploying this to a second region and load balancing between the two regions with Traffic Manager
1. writing a custom probe for the load balancer that checks the helth of other dependent resources
1. deploy a database tier using SQL Server Availability Groups

### Clean up

To clean up, just delete the entire Resource Group

```
az group delete --name $RG --yes --no-wait
```

Note the use of the `--no-wait` argument, this will start the deletion and let it run in the background so we don't have to wait for it to complete. 

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
1. [Extending this lab and Cleanup](./step09.html) *<-- you are here*
1. [CLI commands Summary](./summary.html)