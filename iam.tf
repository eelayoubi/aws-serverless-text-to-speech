data "aws_caller_identity" "current" {}

# NewPost Lambda Role
data "aws_iam_policy_document" "new_post_lambda_policy_doc" {
  statement {
    actions   = ["dynamodb:PutItem"]
    resources = ["arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.posts_ddb_name}"]
  }

  statement {
    actions   = ["sns:Publish"]
    resources = ["arn:aws:sns:*:${data.aws_caller_identity.current.account_id}:${aws_sns_topic.new_posts.name}"]
  }
}

resource "aws_iam_policy" "new_post_lambda_policy" {
  name   = "new_post_lambda_iam_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.new_post_lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "new_post_lambda_policy_attachment" {
  role       = module.new_post_lambda.function_role_name
  policy_arn = aws_iam_policy.new_post_lambda_policy.arn
}

# GetPost Lambda Role
data "aws_iam_policy_document" "get_post_lambda_policy_doc" {
  statement {
    actions   = ["dynamodb:Query", "dynamodb:Scan"]
    resources = ["arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.posts_ddb_name}"]
  }
}

resource "aws_iam_policy" "get_post_lambda_policy" {
  name   = "get_post_lambda_iam_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.get_post_lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "get_post_lambda_policy_attachment" {
  role       = module.get_post_lambda.function_role_name
  policy_arn = aws_iam_policy.get_post_lambda_policy.arn
}

# ConvertToAudio Lambda Function Role
data "aws_iam_policy_document" "convert_post_lambda_policy_doc" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
    resources = ["arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.posts_ddb_name}"]
  }

  statement {
    actions   = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.audio_posts.id}"]
  }

  statement {
    actions   = ["polly:SynthesizeSpeech"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "convert_post_lambda_policy" {
  name   = "convert_post_lambda_iam_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.convert_post_lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "convert_post_lambda_policy_attachment" {
  role       = module.convert_post_to_audio_lambda.function_role_name
  policy_arn = aws_iam_policy.convert_post_lambda_policy.arn
}