# PeopleInfo API

## What and why

This repository contains infra and application code to run small API based on NodeJS and Typescript. Application can write people details to the database, retrieve information and also has status endpoint. 
Additionally some GitHub workflows are stored to automate process of infa creation and application deployment.

After some consideration, decision was made to utilise AWS ECS Fargate service for API and DynamoDB for keeping information. Running the application as AWS ECS with Fargate is the most straightforward and easily achievable solution, especially when considering the "test" application in isolation. ECS offers a great option for more isolated workloads utilizing containers. It can host full applications with several microservices as well.
And DynamoDB is good choice for keeping unstructured datasets in JSON format (what was the part of the initial task) as it is very scalable and can deal with a significant amount of read writes.  The solution is also fully managed.

Main components of the repo are:
1. Terraform code to spin up infrastructure (**iac** folder). After some considerations it was decided to divide terraform code at three parts to keep it manageable and decoupled. Also it aims to avoid the initial errors stemming from circular dependencies. 
	1.1 **basic_iac**: code for VPC, networking, ECS cluster. Which is rarely updated and shall not be run with application-related infra code.
	1.2 **app_iac**: code that creates basic application-related resources like ALB, listeners, IAM, DynamoDB etc. Typically it runs more often than **basic_iac** but does not direcly influence application deployment. 
	1.3 **deploy_iac**: code that is directly related to application deployments. That is mostly ECS and Task Definition pointing to certain image.
2. Application code (**app** folder). Used to store code for Dockerfile and application.
3. Github Workflows (**.github/workflows**) that automate infra creation and application deployments. There are three:
	3.1 **iac_deploy_basic**: workflow to check and run code for **basic_iac**
	3.2 **iac_app**: workflow to check and run code for **app_iac**.
	3.3 **application_build_push_deploy**: workflow that pulls last application or **deploy_iac** changes, runs tests, builds application and pushes it to ECR and in the end runs **deploy_iac** to make application deployment. This workflows also supports automatic semantic versioning based on commit message.

## Prerequisites

1. AWS account with created user or role (for PoC it can have Admin permissions)
2. AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and ECR_REPOSITORY (this one after first **iac_deploy_basic** run) GitHub secrets are created.
3. S3 bucket **people-info-api** is created in AWS account for terraform state files (eu-west-1).

## How to run application in AWS

### 1. **Basic infrastructure**

To run **iac_deploy_basic** worfklow at first, some dummy push to **iac/basic_iac** folder shall be done in main branch.
Workflow will run some terraform checks and create basic infrastructure. More can be read here: !!!!!!!

### 2. **Application basic infrastructure**

To run **iac_app** worfklow at first, some dummy push to **iac/app_iac** folder shall be done in main.
Workflow will run some TF checks and create basic application infrastructure. More can be read here: !!!!!!!

### 3. **Application deployment**

After 1 and 2 steps, we are ready to deploy application. To do that, some dummy push should bes done either to **/iac/app_iac** or **app**. It shall trigger **application_build_push_deploy** workflow. It:
1. Runs npm tests.
2. Defines current version of application and bumps it according to the semantic rules.
3. Builds application image with new version and pushes it to ECR.
4. Creates ECS and points task defintion with new version to it. 

The same flow can be used to make changes to the corresponding parts of the system and day-to-day application deployments. 

### 4. **How to access application**
After 3 step, application can be accessible via external ALB. ALB domain name could be found in AWS console. More information could be found here:

## How to run application in AWS from local machine
It is also possible to run deployment of application in AWS from local machine. For that you need to have AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY or AWS_PROFILE or assumed role to the account.

```bash
cd iac/basic_iac
terraform init; terraform apply
cd ../app_iac
terraform init; terraform apply
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin {YOUR_ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com
cd ../../app
docker build -t {YOUR_ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com/people-info-api:{NEW_VERSION}
docker push {YOUR_ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com/people-info-api:{NEW_VERSION}
cd ../iac/app_iac
terraform init; terraform apply
```

## Additional README Links

- [IAC and Terraform Setup Guide](https://github.com/Pretendfriend/Falafel-API-Server/blob/a005238977a6bb14f39a9830e3c883c1996b0be4/components/README.md)
- [Application Guide](https://github.com/Pretendfriend/Falafel-API-Server/blob/a005238977a6bb14f39a9830e3c883c1996b0be4/application/README.md)

## Monitoring and logging
1. Embedded Cloudwatch monitoring of ECS.
2. Prometheus metrics of application are accessible via ALB endpoint and path **/metrics**.
3. Application logs requests and internal state; sends logs to Cloudwatch log group.

## Possible improvements:

1. **Infrastructure as Code Enhancements**: To make the infrastructure code more modular and manageable.

2. **EKS**: Look into enhancing setup with EKS especially considering case with many microservices that require internal communication.

3. **Security Improvements**: Constantly review and update the security configurations, ensuring that the infrastructure and application are resistant to potential threats.

4. **Deployments Improvements**: Improve deployment process to be able to run tests and deployments from test branches. Improve semantice versioning.

5. **Grafana and Prometheus**: currently metrics are exposed by prometheus client on the Fastify server. As improvement, it could be done by central Prometheus and Grafan installation.
