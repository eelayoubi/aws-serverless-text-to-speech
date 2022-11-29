output "name" {
  value       = aws_dynamodb_table.dynamodb.name
  description = "The name of the DynamoDB table"
}
