# Elasticsearch machine image

This Packer configuration will generate Ubuntu images with Elasticsearch for deploying Elasticsearch clusters on Azure.

The output of running Packer here would be the machine images, as below:

* elasticsearch node image, containing latest Elasticsearch installed (latest version 7.x) and configured with best-practices.

## On Microsoft Azure

Before running Packer for the first time you will need to do a one-time initial setup.

Use PowerShell, and login to AzureRm. See here for more details: https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps. Once logged in, take note of the subscription and tenant IDs which will be printed out. Alternatively, you can retrieve them by running `Get-AzureRmSubscription` once logged-in.

```Powershell
$rgName = "packer-elasticsearch-images"
$location = "East US 2"
New-AzureRmResourceGroup -Name $rgName -Location $location
$Password = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join ''
"Password: " + $Password
$sp = New-AzureRmADServicePrincipal -DisplayName "Azure Packer IKF" -Password $Password
New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $sp.ApplicationId
$sp.ApplicationId
```

Note the resource group name, location, password, sp.ApplicationId as used in the script and emitted as output and update `variables.json`.

To learn more about using Packer on Azure see https://docs.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer

Similarly, using the Azure CLI is going to look something like below:

```bash
export rgName=packer-elasticsearch-images
az group create -n ${rgName} -l eastus2

az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
# outputs client_id, client_secret and tenant_id
az account show --query "{ subscription_id: id }"
# outputs subscription_id
```

## Building

Building the image is done using the following commands:

```bash
packer build -only=azure-arm -var-file=variables.json elasticsearch7-node.packer.json
```
