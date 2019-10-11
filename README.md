# Deploy Elasticsearch on Azure easily

This repository contains a set of tools and scripts to deploy an Elasticsearch cluster on the cloud, using best-practices and state of the art tooling.

***Note:*** This branch supports Elasticsearch 7.x only.

You need to use the latest version of Terraform and Packer for all features to work correctly.

Features:

* Deployment of data and master nodes as separate nodes
* Client node with Kibana and Elasticsearch access
* Load-balancing access to client nodes
* Azure deployment (under `terraform-azure`)

## Usage

Clone this repo to work locally. You might want to fork it in case you need to apply some additional configurations or commit changes to the variables file.

Create images with Packer (see `packer` folder in this repo), and then go into the terraform folder and run `terraform plan`. See README files in each respective folder. 

## tfstate

Once you run `terraform apply` on any of the terraform folders in this repo, a file `terraform.tfstate` will be created. This file contains the mapping between your cloud elements to the terraform configuration. Make sure to keep this file safe.
  
See [this guide](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa#.fbb2nalw6) for a discussion on tfstate management and locking between team members.
