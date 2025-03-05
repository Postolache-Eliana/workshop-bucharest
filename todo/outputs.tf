output "todo_api_endpoint" {
  description = "The URL endpoint for the Todo API"
  value       = "${aws_api_gateway_stage.todo_api.invoke_url}/todos"
}