# Open Source Workloads in Azure with Linux
## Cleanup

1. Stop the running node process by pressing `ctrl+c` and then `enter` in your shell. 
1. Log out of the VM, by typing `exit` at the prompt in the shell. You should now see the prompt switch back from the remote machine to your local machine. 
1. Now lets delete the resource group we created and everything in it.

```
az group delete --name $RG --yes
```

## Lab Navigation
1. [Overview](./)
1. [Setup your environment](./step01.html)
1. [Create a Linux VM in Azure](./step02.html)
1. [Connect to a Linux VM in Azure](./step03.html)
1. [Install components to make our VM a Web Server](./step04.html)
1. [Cleanup](./step05.html) *<-- you are here*

[Back to Index](../../index.html)        