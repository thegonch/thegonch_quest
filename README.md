# Gonch Quest
<a id="readme-top"></a>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#overview">Overview</a>
    </li>
    <li>
      <a href="#setup">Setup</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#aws-configuration">AWS Configuration</a></li>
        <li><a href="#terraform-and-local-configuration">Terraform and Local Configuration</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

The following describes how to execute the "gonchquest" version of the Rearc quest project. This version of the quest project hosts a Node.js express webserver in AWS ECS Fargate for simplicity and ease of use for infrastructure management.

## Overview
The gonchquest project uses a Node.js express webserver that is built up with a Docker image from a Dockerfile to install dependencies and run the source code within. The docker image is uploaded to Amazon ECR for storage and usage by Amazon ECS Fargate. Fargate was chosen for the greater ease of management compared to EC2 instances that require much more management and overhead. The rest of the infrastructure includes an ALB to load balance and host the DNS with a Target Group to route traffic to the express webserver port. The load balancer uses HTTPS with a self-signed certificate uploaded and hosted on AWS ACM. The rest of the Terraform configuration includes a VPC, Security Groups, Service Roles, Private and Public Subnets with an Internet Gateway to prevent external access directly to the internet.

As part of this setup, the secret value to be injected into the Docker container has already been stored in the AWS Secrets Manager.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Setup
<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Prerequisites
- Access to AWS (some paid resources are used as part of this but would be otherwise optional)
- Terraform
- Docker
<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Installation
1. Clone the repo
   ```sh
   git clone https://github.com/thegonch/thegonch_quest.git
   ```
2. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
4. [Install Docker](https://www.docker.com/products/docker-desktop/)
5. Change git remote url to avoid accidental pushes to base project
   ```sh
   git remote set-url origin thegonch/thegonch_quest
   git remote -v # confirm the changes
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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
3. From the root directory of the locally pulled down code from this repository, execute Terraform to create the rest of the resources and start the ECS Fargate task to bring up the website:
```
terraform init
terraform plan -out tf.plan
terraform apply --auto-approve tf.plan
```
4. The output of the above will include the ALB's hostname. Copy and navigate to that in your browser to see the results. Note it may take a few minutes for the website to be fully available. You should be able to verify the following:
   1. The secret word both as an initial result of the index page AND lower down where it is revealed via an environment variable (this is also accessible through the ALB's hostname followed by `/secret_word').
   2. The detection of using AWS and specifically ECS as the container service. As part of this, it may not be able to determine that a container is being used because of the nature of Fargate. (this is also accessible through the ALB's hostname followed by `aws` and `/docker' respectively).
   3. The detection of the Application Load Balancer. (this is also accessible through the ALB's hostname followed by `/loadbalanced').
   4. The detection of TLS (https) via the ACM certificate. (this is also accessible through the ALB's hostname followed by `/tls').

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Stephen Goncher - dagonchucf@aol.com

Project Link: [https://github.com/thegonch/thegonch_quest](https://github.com/thegonch/thegonch_quest)

<p align="right">(<a href="#readme-top">back to top</a>)</p>