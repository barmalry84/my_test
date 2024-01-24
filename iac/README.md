# IAC and Terraform Setup Guide

This repository includes Terraform configurations designed to establish a resilient AWS infrastructure for the API. The architectural components consist of:

1. Basic Infra stack: 
	- A Virtual Private Cloud (VPC) featuring public and private subnets distributed across three availability zones.
	- Elastic Container Registry (ECR) utilized for storing Docker images.
	- ECS cluster.
	- Public subnets establish connectivity with the Internet Gateway (IGW) to facilitate external communication. In contrast, private subnets direct outbound traffic through a Network Address Translation Gateway (NATGW) located within the public subnets.
2. App Infra stack:
	- External ALB to access application (I assume here that access shall be external).
	- Target Groups and Listeners.
	- DynamoDB serving as the database solution.
	- Redics cluster for cache layer between application and database.
	- IAM role for application.
	- ALB Security group
3. Deploy Infra Stack:
	- ECS Fargate to operate the PeopleInfo API in a serverless fashion.
	- Task Definition.
	- ECS security group.

## Workflow TF checks and commands

The `.github/workflows` directory contains a GitHub Actions workflow that:

1. **Validates** Terraform configurations using `terraform fmt`.
2. **Lints** the code with `tflint`.
3. **Inits** Terraform code and creates backend configuration.
4. **Plans** the Terraform changes.
5. **Applies** the changes when code is merged into the main branch.