# DynamoDB Table
module "posts_ddb" {
  source         = "./modules/dynamodb"
  table_name     = var.posts_ddb_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "id"
  hash_key_type  = "S"

  additional_tags = var.posts_ddb_additional_tags
}

# Create NewPost Function
module "new_post_lambda" {
  source         = "./modules/lambda"
  function_name  = "NewPost"
  lambda_handler = "index.handler"
  environment_variables = {
    "POSTS_TABLE" = module.posts_ddb.name
    "SNS_TOPIC"   = aws_sns_topic.new_posts.arn
  }
}

# Create GetPost Function
module "get_post_lambda" {
  source         = "./modules/lambda"
  function_name  = "GetPost"
  lambda_handler = "index.handler"
  environment_variables = {
    "POSTS_TABLE" = module.posts_ddb.name
  }
}

# Create ConvertToAudio Function
module "convert_post_to_audio_lambda" {
  source         = "./modules/lambda"
  function_name  = "ConvertToAudio"
  lambda_handler = "index.handler"
  environment_variables = {
    "POSTS_TABLE" = module.posts_ddb.name
    "BUCKET_NAME" = "${aws_s3_bucket.audio_posts.id}"
  }
}

module "api_gateway" {
  source                 = "./modules/api-gw"
  api_gateway_region     = var.region
  rest_api_name          = "posts"
  api_gateway_account_id = data.aws_caller_identity.current.account_id

  get_post_lambda_function_name = module.get_post_lambda.function_name
  get_post_lambda_function_arn  = module.get_post_lambda.function_invoke_arn

  new_post_lambda_function_name = module.new_post_lambda.function_name
  new_post_lambda_function_arn  = module.new_post_lambda.function_invoke_arn

  depends_on = [
    module.get_post_lambda,
    module.new_post_lambda
  ]
}