# Open Source Workloads in Azure with Linux
## Setup your environment

### Install the The Windows Subsystem for Linux

The Windows Subsystem for Linux is a collection of components that enables native Linux ELF64 binaries to run on Windows. More info [here](https://blogs.msdn.microsoft.com/wsl/2016/04/22/windows-subsystem-for-linux-overview/).

If you are using Windows and have not done so already, follow the instructions [here](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide) to install the Windows Subsystem for Linux. 

### Install the Azure CLI v2.0

If you have not done so already. Follow the 'Install with apt-get for Bash on Ubuntu on Windows' instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest#install-on-windows).

### Create a pair of SSH keys using Bash.

Use *'ssh-keygen'* to create an RSA SSH key of 4096 bits pointing to our e-mail address.

```
ssh-keygen -t rsa -b 4096 -C "your email address"
```

After this command you will be asked for a location to save your powerful key, you can give it a custom location but it's not really necessary unless you actually handle multiple keys.

```
Enter a file in which to save the key (/Users/you/.ssh/id_rsa): [Press enter]
```

Now you will be asked to enter a password to increase the level of security of your key. This password is optional, but if you decide to set it up you will need to enter it every time you interact with your SSH private key:

```
Enter passphrase (empty for no passphrase): [Type a passphrase]
Enter same passphrase again: [Type passphrase again]
```

Now, after your key was created just *cat* the content of your public key (if you used a different location, make sure you use the correct file). This is the key you will be pasting in your azure cli to create the VM.

```
cat ~/.ssh/id_rsa.pub
```

Your key will look something like this. 

```
ssh-rsa 123456789/dTc6wJT+YCOUiLLS6F7Ge4WlCgmH7fW7UIUJpFcXwDv1bWVMQ3chBFFELWEhEjCqX7HAVoSjEF8oAwM0Ik5p6y66J420eeOGBLHkyV    +nBiV0F5WVRKFS5Az1rZy8x/1usbMms/skMnS5Int9QcGIIA9g7Ws9xg28/2XA5IUPUZ0kIKbuSv7bAIqrHaH7WXzUeLeOjUIeW34d9WO52kNqiITjyW1D7kThXKtgS9Y5TEie5MuP8plzz+mBID59EFmdEhBK7QquuT6axXXXXXXXXXXXXXZ1rvoysOHxhDvzVWRuc623pV8PPjiBHiu1Y1T foo@bar.com
```

> When you copy the key to your clipboard for use later in the vm creation process, the key should include "ssh-rsa" and the email address provided

### Login to your Azure Subscription

Enter the following command to login

```
az login
```

1. You will be prompted to open a browser to [https://aka.ms/devicelogin](https://aka.ms/devicelogin) and enter the code provided. After you enter your code you will be prompted to enter your Azure Credentials. 
1. After you successfully login in the browser, if you flip back over to your bash shell, you will see a listing of all the subscriptions you have access to.
1. Ensure the "isDefault" flag is set to true next to the subscription that you want to use. if not use the following command to switch it. 

```
az account set --subscription 'Subscription Name'
```

## Lab Navigation
1. [Overview](./)
1. [Setup your environment](./step01.html) *<-- you are here*
1. [Create a Linux VM in Azure](./step02.html)
1. [Connect to a Linux VM in Azure](./step03.html)
1. [Install components to make our VM a Web Server](./step04.html)
1. [Cleanup](./step05.html)

[Back to Index](../../index.html)        