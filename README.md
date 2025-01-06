# thegonch_quest

The following describes how to execute the "gonchquest" version of the Rearc quest project. This version of the quest project hosts a Node.js express webserver in AWS ECS Fargate for simplicity and ease of use for infrastructure management.

## Overview
The gonchquest project uses a Node.js express webserver that is built up with a Docker image from a Dockerfile to install dependencies and run the source code within. THe docker image is uploaded to Amazon ECR for storage and usage by Amazon ECS Fargate. Fargate was chosen for the greater ease of management compared to EC2 instances that require much more management and overhead. The rest of the infrastructure includes an ALB to load balance and host the DNS with a Target Group to route traffic to the express webserver port. The load balancer uses HTTPS with a self-signed certificate uploaded and hosted on AWS ACM. The rest of the Terraform configuration includes a VPC, Security Groups, Service Roles, Private and Public Subnets with an Internet Gateway to prevent external access directly to the internet.

As part of this setup, the secret value to be injected into the Docker container has already been stored in the AWS Secrets Manager.

## Setup
### Pre-requisites
- Access to AWS (some paid resources are used as part of this but would be otherwise optional)
- Terraform
- Node version 10+, preferably latest
- Docker

### AWS Configuration
1. Create a new AWS IAM user or role that has console access along with access to the following services at a minimum (if not a concern, administrative access will work but least privilege is always desired) and setup local aws credentials to login to the AWS CLI usage with access to:
   1. ECS/Fargate
   2. ECR
   3. VPC/ALB/Target Groups/Security Groups/EIP
   4. S3
   5. ACM
   6. IAM (to create service roles)
   7. Secrets Manager
2. Configure the user/role with access and secret keys. These values can be used within a local `terraform.tfvars` file in the same root directory of this project. NOTE that `terraform.tfvars` is not meant to ever be committed to source control. Defaulting to using us-east-1:
```  
#terraform.tfvars
aws_access_key = "<your_access_key_here>"
aws_secret_key = "<your_secret_key_here>"
aws_region = "us-east-1"
```

### Terraform and Local Configuration
1. Create the S3 bucket for the backend configuration and the ECR repository to store docker images. With Terraform installed locally, navigate first to the setup directory and execute the following commands on your local CLI that has the terraform.tfvars file with the aws:
```
cd setup
terraform init
terraform plan -out tf.plan
terraform apply --auto-approve tf.plan
cd ..
```
2. With the Docker service running locally and AWS credentials configured, execute the following to login to the newly created ECR repository, build the docker image, tag it, and upload it to ECR (executed from the root directory of the locally pulled down code of this repository):
```
export ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
aws ecr get-login-password | docker login -u AWS --password-stdin "https://${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
docker build --platform linux/amd64 -t gonchquest-ecr-repo .
docker tag gonchquest-ecr-repo:latest ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/gonchquest-ecr-repo:latest
docker push ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/gonchquest-ecr-repo:latest
```
1. From the root directory of the locally pulled down code from this repository, execute Terraform to create the rest of the resources and start the ECS Fargate task to bring up the website:
```
terraform init
terraform plan -out tf.plan
terraform apply --auto-approve tf.plan
```
1. The output of the above will include the ALB's URL. Copy and navigate to that in your browser to see the results.