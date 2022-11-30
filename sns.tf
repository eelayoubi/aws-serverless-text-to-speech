resource "aws_sns_topic" "new_posts" {
  name = "new_posts"
}

resource "aws_sns_topic_subscription" "convert_post_subscription" {
  topic_arn = aws_sns_topic.new_posts.arn
  protocol  = "lambda"
  endpoint  = module.convert_post_to_audio_lambda.function_arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.convert_post_to_audio_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.new_posts.arn
}
