resource "aws_sns_topic" "new_posts" {
  name = "new_posts"
}

resource "aws_sns_topic_subscription" "convert_post_subscription" {
  topic_arn = aws_sns_topic.new_posts.arn
  protocol  = "lambda"
  endpoint  = module.convert_post_to_audio_lambda.function_arn
}