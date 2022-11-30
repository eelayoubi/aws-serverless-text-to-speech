variable "function_name" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables to pass to the Lambda function"
}
