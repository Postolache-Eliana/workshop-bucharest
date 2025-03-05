output "api_url" {
  description = "API Gateway URL for the todo API"
  value       = "${aws_api_gateway_deployment.todo_api.invoke_url}/todos"
}