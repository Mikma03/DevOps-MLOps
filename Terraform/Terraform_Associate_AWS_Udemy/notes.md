
# Terraform Basics

All interactions with Terraform occur via the CLI. Terraform is a local tool (runs on the current machine).
The terraform ecosystem also includes providers for many cloud services, and a module repository.
Hashicorp also has products to help teams manage Terraform: Terraform Cloud and Terraform Enter-
prise.

There are a handful of basic terraform commands, including:

    • terraform init
    • terraform validate
    • terraform plan
    • terraform apply
    • terraform destroy

# Example: folder structude

```.
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── backend.tf
├── modules
│   ├── module1
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── module2
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments
    ├── dev
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars
    ├── prod
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars
    └── uat
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tfvars
```