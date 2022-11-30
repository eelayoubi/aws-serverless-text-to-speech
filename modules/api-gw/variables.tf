variable "rest_api_name" {
  type        = string
  description = "Name of the API Gateway created"
}

variable "api_gateway_region" {
  type        = string
  description = "The region in which to create/manage resources"
}

variable "api_gateway_account_id" {
  type        = string
  description = "The account ID in which to create/manage resources"
}

variable "get_post_lambda_function_name" {
  type        = string
  description = "The name of the Get Post Lambda function"
}

variable "get_post_lambda_function_arn" {
  type        = string
  description = "The ARN of the Get Post Lambda function"
}

variable "new_post_lambda_function_name" {
  type        = string
  description = "The name of the New Post Lambda function"
}

variable "new_post_lambda_function_arn" {
  type        = string
  description = "The ARN of the New Post Lambda function"
}

variable "rest_api_stage_name" {
  type        = string
  description = "The name of the API Gateway stage"
  default     = "dev"
}
