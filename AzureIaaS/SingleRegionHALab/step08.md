# Single Region High Availability Lab 
## Step 8 - 'Look Mom its magic'

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


## Lab Navigation
1. [Overview](./) 
1. [Connect to the Azure Cloud Shell](./step01.html)
1. [Select your subscription](./step02.html)
1. [Create the Resource Group](./step03.html)
1. [Create the Availability Set](./step04.html)
1. [Create the first vm](./step05.html)
1. [Create the second VM same as the first](./step06.html)
1. [Add the load balancer](./step07.html)
1. [Look Mom its magic](./step08.html) *<-- you are here*
1. [Extending this lab and Cleanup](./step09.html)
1. [CLI commands Summary](./summary.html)