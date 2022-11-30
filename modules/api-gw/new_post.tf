resource "aws_api_gateway_method" "rest_api_new_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "rest_api_new_post_method_response_200" {
  rest_api_id     = aws_api_gateway_rest_api.rest_api.id
  resource_id     = aws_api_gateway_resource.rest_api_resource.id
  http_method     = aws_api_gateway_method.rest_api_new_post_method.http_method
  status_code     = 200
  response_models = { "application/json" = "Empty" }
}

resource "aws_api_gateway_method_response" "rest_api_new_post_method_response_400" {
  rest_api_id     = aws_api_gateway_rest_api.rest_api.id
  resource_id     = aws_api_gateway_resource.rest_api_resource.id
  http_method     = aws_api_gateway_method.rest_api_new_post_method.http_method
  status_code     = 400
  response_models = { "application/json" = "Empty" }
}

resource "aws_api_gateway_integration" "rest_api_new_post_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_resource.id
  http_method             = aws_api_gateway_method.rest_api_new_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.new_post_lambda_function_arn

  depends_on = [aws_api_gateway_method_response.rest_api_new_post_method_response_200, aws_api_gateway_method_response.rest_api_new_post_method_response_400]
}

resource "aws_api_gateway_integration_response" "rest_api_new_post_integration_response_200" {
  depends_on = [
    aws_api_gateway_integration.rest_api_new_post_method_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.rest_api_new_post_method.http_method
  status_code = aws_api_gateway_method_response.rest_api_new_post_method_response_200.status_code
}

resource "aws_api_gateway_integration_response" "rest_api_new_post_integration_response_400" {
  depends_on = [
    aws_api_gateway_integration.rest_api_new_post_method_integration
  ]
  rest_api_id       = aws_api_gateway_rest_api.rest_api.id
  resource_id       = aws_api_gateway_resource.rest_api_resource.id
  http_method       = aws_api_gateway_method.rest_api_new_post_method.http_method
  status_code       = aws_api_gateway_method_response.rest_api_new_post_method_response_400.status_code
  selection_pattern = ".*\"Error\".*"
  response_templates = {
    "application/json" = <<EOF
    {
        "errorMessage":" $input.path('$.errorMessage')",
        "statusCode": 401
    }
    EOF
  }
}

resource "aws_lambda_permission" "api_gateway_new_post_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.new_post_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_new_post_method.http_method}${aws_api_gateway_resource.rest_api_resource.path}"
}
