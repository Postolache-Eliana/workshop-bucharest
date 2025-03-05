# DynamoDB - this is the database where we will store our todos
resource "aws_dynamodb_table" "todos_table" {
  name         = "toDos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ToDoId"

  attribute {
    name = "ToDoId"
    type = "S"
  }

  tags = {
    Name = "todos-table"
  }
}

# IAM - let's create an IAM role for our Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "todo_api_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# IAM - let's create an IAM policy for our Lambda functions to access DynamoDB
resource "aws_iam_policy" "lambda_policy" {
  name        = "todo_api_lambda_policy"
  description = "IAM policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.todos_table.arn
      },
    ]
  })
}

# IAM - attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# IAM - attach the AWSLambdaBasicExecutionRole policy to the role
# this policy allows the Lambda function to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda GET - first let's create a zip file for our Lambda functions
data "archive_file" "get_todos" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/get_todos"
  output_path = "${path.module}/lambda_functions/get_todos.zip"
}

# Lambda POST - first let's create a zip file for our Lambda functions
data "archive_file" "add_todo" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/add_todo"
  output_path = "${path.module}/lambda_functions/add_todo.zip"
}

# Lambda GET - lambda function to get all todos
resource "aws_lambda_function" "get_todos" {
  filename      = "${path.module}/lambda_functions/get_todos.zip"
  function_name = "getToDos"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.get_todos.output_base64sha256

  runtime = "nodejs22.x"

  environment {
    variables = {
      TODO_TABLE_NAME = aws_dynamodb_table.todos_table.name
    }
  }
}

# Lambda POST - lambda function to add a todo
resource "aws_lambda_function" "add_todo" {
  filename      = "${path.module}/lambda_functions/add_todo.zip"
  function_name = "addToDo"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.add_todo.output_base64sha256

  runtime = "nodejs22.x"

  environment {
    variables = {
      TODO_TABLE_NAME = aws_dynamodb_table.todos_table.name
    }
  }
}

# API Gateway - let's create a REST API Gateway to expose our Lambda functions
resource "aws_api_gateway_rest_api" "todo_api" {
  name        = "ToDoAPI"
  description = "API Gateway for todo list application"
}

# API Gateway - let's create a resource for our GET and POST Lambda functions
resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  path_part   = "todos"
}

# Configuration for the GET /todos method, to get all todos
# API Gateway - add a method to GET /todos
resource "aws_api_gateway_method" "get_todos" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway - GET /todos —> Lambda function
resource "aws_api_gateway_integration" "get_todos" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = aws_api_gateway_method.get_todos.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_todos.invoke_arn
}

# Configuration for the POST /todos method, to add a todo
# API Gateway - add a method to POST /todos
resource "aws_api_gateway_method" "add_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway - POST /todos —> Lambda function
resource "aws_api_gateway_integration" "add_todo" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = aws_api_gateway_method.add_todo.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_todo.invoke_arn
}

# Lambda Permissions - allow API Gateway to invoke our Lambda functions
resource "aws_lambda_permission" "get_todos" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_todos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "add_todo" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*/*"
}

# API Gateway - add a deployment for our API
resource "aws_api_gateway_deployment" "todo_api" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id

  # redeploy the API gateway when the Lambda functions change
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.todos.id,
      aws_api_gateway_method.get_todos.id,
      aws_api_gateway_method.add_todo.id,
      aws_api_gateway_integration.get_todos.id,
      aws_api_gateway_integration.add_todo.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway - create a stage for our API
resource "aws_api_gateway_stage" "todo_api" {
  deployment_id = aws_api_gateway_deployment.todo_api.id
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  stage_name    = "demo"
}