output "function_arn" {
  value = aws_lambda_function.function.arn
}

output "function_invoke_arn" {
  value = aws_lambda_function.function.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.function.function_name
}

output "function_role_arn" {
  value = aws_lambda_function.function.role
}

output "function_role_name" {
  value = aws_iam_role.lambda_function_role.name
}