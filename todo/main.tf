# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "todo_api_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Lambda function for getting all todos
resource "aws_lambda_function" "get_todos" {
  filename      = "${path.module}/lambda_functions/get_todos.zip"
  function_name = "getTodos"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  source_code_hash = filebase64sha256("${path.module}/lambda_functions/get_todos.zip")
}

# Lambda function for adding a todo
resource "aws_lambda_function" "add_todo" {
  filename      = "${path.module}/lambda_functions/add_todo.zip"
  function_name = "addTodo"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  source_code_hash = filebase64sha256("${path.module}/lambda_functions/add_todo.zip")
}

# API Gateway
resource "aws_api_gateway_rest_api" "todo_api" {
  name        = "TodoAPI"
  description = "API for todo list application"
}

# API Gateway resource for /todos
resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  path_part   = "todos"
}

# API Gateway method for GET /todos
resource "aws_api_gateway_method" "get_todos" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway integration for GET /todos
resource "aws_api_gateway_integration" "get_todos" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = aws_api_gateway_method.get_todos.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_todos.invoke_arn
}

# API Gateway method for POST /todos
resource "aws_api_gateway_method" "add_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway integration for POST /todos
resource "aws_api_gateway_integration" "add_todo" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = aws_api_gateway_method.add_todo.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_todo.invoke_arn
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "todo_api" {
  depends_on = [
    aws_api_gateway_integration.get_todos,
    aws_api_gateway_integration.add_todo
  ]

  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  stage_name  = "dev"
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "get_todos" {
  statement_id  = "AllowAPIGatewayInvokeGetTodos"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_todos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "add_todo" {
  statement_id  = "AllowAPIGatewayInvokeAddTodo"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_todo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}
