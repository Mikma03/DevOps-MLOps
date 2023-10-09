<!-- TOC -->

- [Official documentation](#official-documentation)
  - [Terraform Language Documentation](#terraform-language-documentation)
  - [Terraform CLI Documentation](#terraform-cli-documentation)
  - [Providers: on AWS example](#providers-on-aws-example)
- [Terraform - materials](#terraform---materials)
  - [BOOKS: Terraform](#books-terraform)
- [Udemy courses](#udemy-courses)
- [Terraform on Azure](#terraform-on-azure)
- [Terraform on AWS](#terraform-on-aws)
- [Terraform on GCP](#terraform-on-gcp)
- [Terraform workflow](#terraform-workflow)
  - [Step by step Terraform workflow](#step-by-step-terraform-workflow)
  - [Terraform expected folder structure](#terraform-expected-folder-structure)
- [Description of Terraform repo](#description-of-terraform-repo)

<!-- /TOC -->

# Official documentation

## Terraform Language Documentation

- https://developer.hashicorp.com/terraform/language

## Terraform CLI Documentation

- https://developer.hashicorp.com/terraform/cli

## Providers: on AWS example

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs

---

# Terraform - materials

## BOOKS: Terraform

- Terraform: Up and Running, 3rd Edition

  - https://learning.oreilly.com/library/view/terraform-up-and/9781098116736/

- Infrastructure as Code, Patterns and Practices

  - https://www.manning.com/books/infrastructure-as-code-patterns-and-practices

- Terraform Cookbook 2nd Edition
  - https://learning.oreilly.com/library/view/terraform-cookbook/9781804616420/

# Udemy courses

- HashiCorp Certified: Terraform Associate 2022

  - https://www.udemy.com/course/terraform-beginner-to-advanced/

- HashiCorp Certified: Terraform Associate - Hands-On Labs

  - https://www.udemy.com/course/terraform-hands-on-labs/

- Complete Terraform Course

  - https://www.udemy.com/course/complete-terraform-course-beginner-to-advanced/

- More than Certified in Terraform
  - https://www.udemy.com/course/terraform-certified/

# Terraform on Azure

- Azure - HashiCorp Certified: Terraform Associate

  - https://www.udemy.com/course/hashicorp-certified-terraform-associate-on-azure-cloud/

- Terraform on Azure

  - https://www.udemy.com/course/terraform-on-azure-services/

- Terraform on Azure with IaC DevOps SRE
  - https://www.udemy.com/course/terraform-on-azure-with-iac-azure-devops-sre-real-world-25-demos/

# Terraform on AWS

- HashiCorp Certified: Terraform Associate - 50 Practical Demos

  - https://www.udemy.com/course/hashicorp-certified-terraform-associate-step-by-step/

- Terraform on AWS EKS Kubernetes IaC SRE
  - https://www.udemy.com/course/terraform-on-aws-eks-kubernetes-iac-sre-50-real-world-demos/

# Terraform on GCP

- Terraform for Beginners using GCP
  - https://www.udemy.com/course/terraform-for-beginners-using-google-cloud/

# Terraform workflow

## Step by step Terraform workflow

1. **Initialize the Terraform working directory**: Run the command `terraform init` in the directory containing your Terraform configuration files. This command downloads the necessary provider plugins and sets up the backend for storing the Terraform state.

2. **Validate the configuration**: Run `terraform validate` to ensure the syntax of your configuration files is correct and that all required arguments have been provided.

3. **Review the execution plan**: Run `terraform plan` to see the changes that will be made to your infrastructure. This step allows you to verify the resources that will be created, modified, or destroyed.

4. **Apply the changes**: Run `terraform apply` to create or update the resources defined in your configuration files. You'll be prompted to confirm that you want to proceed with the changes. Review the plan, and if everything looks good, type `yes` to apply the changes.

5. **Inspect the state**: Use `terraform show` to display the current state of your infrastructure.

6. **Modify the infrastructure**: If you need to modify your infrastructure, edit the configuration files and repeat steps 2-5.

7. **Destroy the infrastructure**: When you no longer need the infrastructure, run `terraform destroy` to delete all the resources created by Terraform. You'll be prompted to confirm that you want to proceed with the destruction.

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

- `environments`: This directory contains subdirectories for different environments, such as production and staging. Each environment has its own `main.tf`, `variables.tf`, and `terraform.tfvars` files to define the resources, input variables, and environment-specific variable values, respectively.

- `modules`: This directory contains reusable Terraform modules for different infrastructure components, such as compute, network, and storage. Each module has its own `main.tf`, `variables.tf`, and `outputs.tf` files to define the resources, input variables, and outputs, respectively.

- `README.md`: This file contains documentation about the project, including descriptions of the environments, modules, and how to use them.

This folder structure promotes modularity and reusability by separating environment-specific configurations from the reusable modules. You can extend this structure as needed to accommodate additional environments, modules, or other organizational requirements.

# Description of Terraform repo

- `main.tf`: This file is the primary entry point for your Terraform configurations. It typically contains resource definitions and may reference modules for organizing your infrastructure code. It's the central place where you define your infrastructure resources and configurations.

- `variables.tf`: This file contains the input variable declarations for your Terraform configurations. Variables allow you to parameterize your Terraform code, making it more flexible and reusable. By declaring variables in this file, you can pass different values for each environment or module, making your infrastructure code more adaptable to various use cases.

- `outputs.tf`: This file contains output variable declarations. Outputs are used to extract and expose data from your Terraform configuration. They are useful for displaying important information, such as resource IDs, IP addresses, or DNS names. Outputs can also be used to pass data between different Terraform configurations or to integrate with external tools and systems.

- `terraform.tfvars` or `*.auto.tfvars`: These files are used to define the values for the input variables declared in `variables.tf`. You can have separate `terraform.tfvars` or `*.auto.tfvars` files for each environment to provide environment-specific variable values. Terraform automatically loads `*.auto.tfvars` files, whereas you need to specify the -var-file flag to load a `terraform.tfvars` file when running Terraform commands.

- `backend.tf`: This file is used to configure the remote backend for storing your Terraform state. A remote backend allows multiple team members to collaborate on Terraform projects and provides features like locking and versioning. Common remote backends include Amazon S3, Google Cloud Storage, or Terraform Cloud.

- `providers.tf`: This file is used to configure the providers required by your Terraform configurations. Providers are responsible for managing resources in different cloud platforms or services. For example, the AWS provider is used to manage AWS resources, and the Google provider is used to manage Google Cloud resources.
