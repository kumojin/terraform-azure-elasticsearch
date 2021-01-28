# Elasticsearch machine image

This Packer configuration will generate Ubuntu based images for Elasticsearch and Kibana for deployment of Elasticsearch clusters on Azure.

## Configuration

Create a new resource group in which to create the images
```bash
az group create -n <resource_group_name> -l <location>
```

Populate `variables.json` with the information returned with the following commands
```bash
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
az account show --query "{ subscription_id: id }"
```

## Building

Building the image is done using the following commands
```bash
packer build -only=azure-arm -var-file=variables.json elasticsearch7-node.packer.json
packer build -only=azure-arm -var-file=variables.json kibana7-node.packer.json
```
