# Open Source Workloads in Azure with Linux
## Connect to a Linux VM in Azure

### First we need to know the FQDN for our VM, we can get that with the following command

```
az vm show -g $RG -n myosslabvm -d --query "fqdns"
```

### Now we can SSH into the VM (Note replace myUserName and myDomainName with the values you used)

```
ssh myUserName@myDomainName
```

Mine looks like this:

```
ssh shawn@zzoe5ntiwjdl2fg.westus2.cloudapp.azure.com
```

### The first time you connect you will be prompted with the following warning, enter `yes` to agree.

```
The authenticity of host 'zzoe5ntiwjdl2fg.westus2.cloudapp.azure.com (52.229.39.168)' can't be established.
ECDSA key fingerprint is 91:f8:b7:ee:20:b2:e0:0b:6a:84:bc:94:8f:59:9c:f8.
Are you sure you want to continue connecting (yes/no)?
```

### You should see your prompt change from something like this:

```
sweisfel@MININT-L8O1KA6:~$
```

to something like this:

```
[shawn@myosslabvm ~]$
```

Your shell is now tunneled into the remote machine in Azure. It is just like you are sitting in the Azure data center looking at the shell running on the VM. 


## Lab Navigation
1. [Overview](./)
1. [Setup your environment](./step01.html)
1. [Create a Linux VM in Azure](./step02.html)
1. [Connect to a Linux VM in Azure](./step03.html) *<-- you are here*
1. [Install components to make our VM a Web Server](./step04.html)
1. [Cleanup](./step05.html)

[Back to Index](../../index.html)        
