resource "random_string" "s3_bucket_suffix" {
  length  = 7
  special = false
  upper   = false
}

resource "aws_s3_bucket" "audio_posts" {
  bucket        = "audio-posts-${random_string.s3_bucket_suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "audio_posts_bucket_acl" {
  bucket = aws_s3_bucket.audio_posts.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "audio_posts_access_block" {
  bucket = aws_s3_bucket.audio_posts.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.audio_posts.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "${aws_s3_bucket.audio_posts.arn}/*",
    ]
  }
}