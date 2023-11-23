# Backup and Restore Disaster Recovery Implementation on Hybrid Cloud

## Overview

This project aims to provide a robust and scalable solution for disaster recovery by implementing a hybrid cloud approach. Leveraging the power of Terraform, AWS Cloud, Azure Cloud, Cloudflare, Ansible, Python, ShellScripts, Nginx, Certbot, Node.js, AWS RDS MySQL, and Azure MySQL DB, the Backup and Restore Disaster Recovery Implementation ensures the continuity of critical applications in the event of a disaster.

### Project Structure

The project is organized into three major directories:

1. **Production-Infrastructure:** Contains Terraform code for the production infrastructure on AWS.
2. **Recovery-Infrastructure:** Holds Terraform code for the disaster recovery infrastructure on Azure.
3. **nodejs-application:** Includes the Node.js basic application code.

## Local Development Requirements

Ensure your local machine meets the following technology stack requirements:

- **Terraform:** Version 1.6.3 or higher, enforced within Terraform code using `required_version`.
- **Ansible:** Version 2.15.6 or higher.

## Getting Started

### Setting up Production Infrastructure on AWS

![](.prod.gif)


1. Navigate to the `Production-Infrastructure` directory.
2. Rename `terraform.tfvars.sample` to `terraform.tfvars`.
3. Add all necessary credentials in `terraform.tfvars`.

Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```
### Disaster Recovery Procedure

![](.recovered.gif)

#### In case of a disaster, switch to the Recovery-Infrastructure directory.

```bash
terraform init
terraform plan --var-file ../Production-Infrastructure/terraform.tfvars
terraform apply --var-file ../Production-Infrastructure/terraform.tfvars
```