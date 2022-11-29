variable "posts_ddb_name" {
  type    = string
  default = "posts"
}

variable "billing_mode" {
  type    = string
  default = "PROVISIONED"
}

variable "read_capacity" {
  type    = number
  default = 5
}

variable "write_capacity" {
  type    = number
  default = 5
}

variable "hash_key" {
  type    = string
  default = "id"
}

variable "hash_key_type" {
  type    = string
  default = "S"
}

variable "posts_ddb_additional_tags" {
  type = map(string)
  default = {
    Name = "posts"
  }
}
