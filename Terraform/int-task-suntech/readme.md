<!-- TOC -->

- [Introduction](#introduction)
  - [Initial tools](#initial-tools)
- [Official documentation](#official-documentation)
  - [Terraform Language Documentation](#terraform-language-documentation)
  - [Terraform CLI Documentation](#terraform-cli-documentation)
  - [Providers: on AWS example](#providers-on-aws-example)
- [Requirements](#requirements)
- [How to use cf2tf](#how-to-use-cf2tf)
- [Brainboard](#brainboard)
- [Architecture](#architecture)
  - [Terraform code](#terraform-code)
- [Terraform workflow](#terraform-workflow)
  - [Step by step Terraform workflow](#step-by-step-terraform-workflow)
  - [Terraform expected folder structure](#terraform-expected-folder-structure)

<!-- /TOC -->

# Introduction

As a initial step: complexity of task was checked, namely translation from YAML format (**CloudFormation**) to '.tf' file (**Terraform**).

Oryginal CloudFormation code link:

> https://arcgisstore.s3.us-east-1.amazonaws.com/110/templates/arcgis-server-ha.template.json

As cf2tf tool is under developement, that means it is not perfect.

Moreover oryginal scripts, commands from CloudFromation were removed as main tasks are:

- estimate costs
- propose entry point for ifrastructure

## Initial tools

- Python

> https://www.python.org/

- cf2tf

> https://github.com/DontShaveTheYak/cf2tf

# Official documentation

## Terraform Language Documentation

- https://developer.hashicorp.com/terraform/language

## Terraform CLI Documentation

- https://developer.hashicorp.com/terraform/cli

## Providers: on AWS example

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs

# Requirements

> Python >= 3.7

> cf2tf >= 0.5.0

# How to use cf2tf

Open terminal session in directory where .yaml file is located and next execute

> 'cf2tf my_template.yaml > main.tf'

Assumption here is only that cf2tf is already installed

# Brainboard

Interesting new tool which support preparing ifrastructure for cloud deployments. This is UI tool, but with git support as well as CICD approach.

What is also adventage of that tool: it's support different environment versions like PROD, STAGE, DEV

> https://www.brainboard.co/

Medium article

> https://medium.com/@mike_tyson_cloud/no-one-should-ever-write-a-single-line-of-terrafom-code-5488d95211a8

# Architecture

Base on brainboard platform initial architecture diagram was prapared and can be reached under following path:

> Terraform/int-task-suntech/Brainboard-arch.png

Next step was prepare something like template for further improvements.

## Terraform code

Terraform file was prepared and could be found under followig path

> Terraform/int-task-suntech/brainboard-terra.tf

# Terraform workflow

## Step by step Terraform workflow

1. **Initialize the Terraform working directory**: Run the command 'terraform init' in the directory containing your Terraform configuration files. This command downloads the necessary provider plugins and sets up the backend for storing the Terraform state.

2. **Validate the configuration**: Run 'terraform validate' to ensure the syntax of your configuration files is correct and that all required arguments have been provided.

3. **Review the execution plan**: Run 'terraform plan' to see the changes that will be made to your infrastructure. This step allows you to verify the resources that will be created, modified, or destroyed.

4. **Apply the changes**: Run 'terraform apply' to create or update the resources defined in your configuration files. You'll be prompted to confirm that you want to proceed with the changes. Review the plan, and if everything looks good, type 'yes' to apply the changes.

5. **Inspect the state**: Use 'terraform show' to display the current state of your infrastructure.

6. **Modify the infrastructure**: If you need to modify your infrastructure, edit the configuration files and repeat steps 2-5.

7. **Destroy the infrastructure**: When you no longer need the infrastructure, run 'terraform destroy' to delete all the resources created by Terraform. You'll be prompted to confirm that you want to proceed with the destruction.


## Terraform expected folder structure

    .
    ├── environments
    │   ├── production
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   └── terraform.tfvars
    │   └── staging
    │       ├── main.tf
    │       ├── variables.tf
    │       └── terraform.tfvars
    ├── modules
    │   ├── compute
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── network
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   └── storage
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └─── README.md


Descrition

- 'environments': This directory contains subdirectories for different environments, such as production and staging. Each environment has its own 'main.tf', 'variables.tf', and 'terraform.tfvars' files to define the resources, input variables, and environment-specific variable values, respectively.

- 'modules': This directory contains reusable Terraform modules for different infrastructure components, such as compute, network, and storage. Each module has its own 'main.tf', 'variables.tf', and 'outputs.tf' files to define the resources, input variables, and outputs, respectively.

- 'README.md': This file contains documentation about the project, including descriptions of the environments, modules, and how to use them.

This folder structure promotes modularity and reusability by separating environment-specific configurations from the reusable modules. You can extend this structure as needed to accommodate additional environments, modules, or other organizational requirements.