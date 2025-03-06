# 🚀 AWS Workshop - Cloud Architecture Demos

This repository contains workshop materials for cloud architecture demonstrations, featuring both serverful and serverless approaches to building AWS applications.

## Workshop Overview

This workshop consists of two parts:

1. **Part 1: Serverful Web Architecture** - A high-availability web application using EC2, Auto Scaling, and Load Balancing
2. **Part 2: Serverless Todo API** - A fully serverless REST API using Lambda, API Gateway, and DynamoDB

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed (v1.0+)
- Git

## AWS User Setup

To create a user for Terraform with the necessary permissions:

1. Go to [AWS IAM Console](https://us-east-1.console.aws.amazon.com/iam/home#/users)
2. Click "Create user"
3. Add User name "terraform" and click "Next"
4. Click "Attach policies directly" and select the following policies:
   - AmazonVPCFullAccess
   - AmazonEC2FullAccess
   - AmazonAPIGatewayAdministrator
   - AWSLambda_FullAccess
   - IAMFullAccess
   - AmazonDynamoDBFullAccess
5. Click "Next"
6. Click "Create user"

Then create access keys for the user:

1. Select the user "terraform"
2. Go to "Security credentials"
3. Click "Create access key"
4. Choose "Command Line Interface (CLI)"
5. Click "Next" and "Create access key"
6. Save the access key and secret key
7. Configure your environment:

```bash
# In the root of the directory
mkdir -p .aws
cat > .aws/creds << EOF
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
EOF
```

## 🌐 Part 1: Serverful Web Architecture

This part demonstrates a highly available web application using EC2 instances behind a load balancer.

### Architecture

- VPC with public subnets across 3 availability zones
- EC2 instances in an Auto Scaling Group
- Application Load Balancer to distribute traffic
- Security Groups for network access control

### Deployment

```bash
cd webserver
terraform init
terraform plan
terraform apply
```

After deployment, you can access your web application via the load balancer URL provided in the Terraform output.

### Key Components

- VPC Configuration: Custom network with public subnets
- Auto Scaling Group: Ensures high availability by maintaining the desired number of instances
- Launch Template: Defines the EC2 instance configuration with a bootstrap script
- Load Balancer: Routes traffic to healthy instances across availability zones

## ☁️ Part 2: Serverless Todo API

This part demonstrates a serverless REST API for managing todo items.

### Architecture

- Lambda functions for backend logic
- API Gateway for RESTful API interface
- DynamoDB for persistent data storage
- IAM roles and policies for security

### Deployment

```bash
cd todo
terraform init
terraform plan
terraform apply
```

### Testing the API

After deployment, you can retrieve the API endpoint:

```bash
# Get the API endpoint from Terraform output
export TODO_API_ENDPOINT=$(terraform output -raw todo_api_endpoint)
echo $TODO_API_ENDPOINT
```

Test the API with curl:

```bash
# Get all todos
curl -X GET $TODO_API_ENDPOINT

# Add a new todo
curl -X POST $TODO_API_ENDPOINT \
  -H "Content-Type: application/json" \
  -d '{"text": "Plan a meeting with Alex to prepare the AWS workshop"}'
```

### Key Components

- Lambda Functions:
  - getToDos: Retrieves all todo items from DynamoDB
  - addToDo: Creates a new todo item in DynamoDB
- API Gateway: RESTful interface with two endpoints:
  - GET /todos: List all todo items
  - POST /todos: Create a new todo item
- DynamoDB: NoSQL database with a single table for todo items

## 🧹 Cleaning Up

To avoid incurring charges, remove all resources when finished:

```bash
# Clean up Todo API resources
cd todo
terraform destroy

# Clean up Webserver resources
cd ../webserver
terraform destroy
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.