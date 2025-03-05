# Workshop-bucharest

A workshop for the university in Bucharest

## Create AWS User for terraform

To create a user for terraform, follow the steps below:

1. Go to AWS IAM Console (https://us-east-1.console.aws.amazon.com/iam/home#/users)
2. Click on "Create user"
3. Add as User name "terraform" and click on "Next"
4. Click "Attach policies directly" and select the following policies:
   1. AmazonVPCFullAccess
   2. AmazonEC2FullAccess
   3. AmazonAPIGatewayAdministrator
   4. AWSLambda_FullAccess
   5. IAMFullAccess
   6. AmazonDynamoDBFullAccess
5. Click on "Next"
6. Click on "Create user"

Then create an access key for the user and save the access key and secret key.

1. Click on the user "terraform"
2. Go to the "Security credentials" tab
3. Click on "Create access key"
4. Click on "Create access key"
5. Save the access key and secret key
6. Export the access key and secret key as environment variables

    ```bash
    export AWS_ACCESS_KEY_ID=""
    export AWS_SECRET_ACCESS_KEY=""
    ```

## TODO API Workshop

This workshop includes a serverless TODO API built with:

- AWS Lambda functions for adding and retrieving TODOs
- API Gateway to create REST endpoints
- DynamoDB for persistent storage of TODO items

### Preparing Lambda Functions

Before deploying, make sure to install the required dependencies for the Lambda functions:

```bash
# Install dependencies for get_todos Lambda
cd lambda_functions/get_todos
npm init -y
npm install aws-sdk
cd ../..

# Install dependencies for add_todo Lambda
cd lambda_functions/add_todo
npm init -y
npm install aws-sdk
cd ../..

# Package Lambda functions
cd lambda_functions
zip -r get_todos.zip get_todos/
zip -r add_todo.zip add_todo/
cd ..
````

After deployment, you can test the API using:

```bash
# Get all todos
curl -X GET <api_url>

# Add a new todo
curl -X POST <api_url> -H "Content-Type: application/json" -d '{"text": "New todo item"}'
