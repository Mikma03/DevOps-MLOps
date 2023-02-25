<!-- TOC -->

- [Configuration Management Versus Provisioning](#configuration-management-versus-provisioning)
- [Procedural Language Versus Declarative Language](#procedural-language-versus-declarative-language)
- [General-Purpose Language Versus Domain-Specific Language](#general-purpose-language-versus-domain-specific-language)
- [Master Versus Masterless](#master-versus-masterless)
- [Agent Versus Agentless](#agent-versus-agentless)
- [Installing Terraform](#installing-terraform)

<!-- /TOC -->

# Configuration Management Versus Provisioning

Chef, Puppet, and Ansible are all configuration management tools, whereas CloudFormation, Terraform, OpenStack Heat, and Pulumi are all provisioning tools.

# Procedural Language Versus Declarative Language

Chef and Ansible encourage a procedural style in which you write code that specifies, step by step, how to achieve some desired end state.

Terraform, CloudFormation, Puppet, OpenStack Heat, and Pulumi all encourage a more declarative style in which you write code that specifies your desired end state, and the IaC tool itself is responsible for figuring out how to achieve that state.

With Terraform’s declarative approach, the code always represents the latest state of your infrastructure. At a glance, you can determine what’s currently deployed and how it’s configured, without having to worry about history or timing.

# General-Purpose Language Versus Domain-Specific Language

Chef and Pulumi allow you to use a general-purpose programming language (GPL) to manage infrastructure as code: Chef supports Ruby; Pulumi supports a wide variety of GPLs, including JavaScript, TypeScript, Python, Go, C#, Java, and others. Terraform, Puppet, Ansible, CloudFormation, and OpenStack Heat each use a domain-specific language (DSL) to manage infrastructure as code: Terraform uses HCL; Puppet uses Puppet Language; Ansible, CloudFormation, and OpenStack Heat use YAML (CloudFormation also supports JSON).

# Master Versus Masterless

By default, Chef and Puppet require that you run a master server for storing the state of your infrastructure and distributing updates. Every time you want to update something in your infrastructure, you use a client (e.g., a command-line tool) to issue new commands to the master server, and the master server either pushes the updates out to all of the other servers or those servers pull the latest updates down from the master server on a regular basis.

Ansible, CloudFormation, Heat, Terraform, and Pulumi are all masterless by default. Or, to be more accurate, some of them rely on a master server, but it’s already part of the infrastructure you’re using and not an extra piece that you need to manage. For example, Terraform communicates with cloud providers using the cloud provider’s APIs, so in some sense, the API servers are master servers, except that they don’t require any extra infrastructure or any extra authentication mechanisms (i.e., just use your API keys).

# Agent Versus Agentless

Chef and Puppet require you to install agent software (e.g., Chef Client, Puppet Agent) on each server that you want to configure. The agent typically runs in the background on each server and is responsible for installing the latest configuration management updates.

Ansible, CloudFormation, Heat, Terraform, and Pulumi do not require you to install any extra agents. Or, to be more accurate, some of them require agents, but these are typically already installed as part of the infrastructure you’re using. For example, AWS, Azure, Google Cloud, and all of the other cloud providers take care of installing, managing, and authenticating agent software on each of their physical servers. As a user of Terraform, you don’t need to worry about any of that: you just issue commands, and the cloud provider’s agents execute them for you on all of your servers.

# Installing Terraform

- https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/ch02.html#:-:text=Installing%20Terraform

For Terraform to be able to make changes in your AWS account, you will need to set the AWS credentials for the IAM user you created earlier as the environment variables **AWS_ACCESS_KEY_ID** and A**WS_SECRET_ACCESS_KEY**


Note that these environment variables apply only to the current shell, so if you reboot your computer or open a new terminal window, you’ll need to export these variables again.