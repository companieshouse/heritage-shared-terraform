# ceu-terraform
## What is this repo?
This repo contains the required infrastructure for the CEU Application stack
This will be deployed to Dev, Staging and Live so the Terraform code is generic with var files per account in the profiles sub-directory (per group).

## The Groups of Terraform

### groups/ceu-infrastructure
Contains any existing resources created in AWS for the CEU Application, additional resources can be added as and when required.
