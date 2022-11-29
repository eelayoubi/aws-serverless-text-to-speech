resource "aws_dynamodb_table" "dynamodb" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  range_key      = var.range_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  dynamic "attribute" {
    for_each = var.range_key == null ? [] : [1]
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  tags = merge(
    var.additional_tags,
    {
      Deployer = "terraform"
    }
  )
}