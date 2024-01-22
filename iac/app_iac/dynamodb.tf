resource "aws_dynamodb_table" "people_info" {
  name         = "PeopleInfo"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "person_name"
    type = "S"
  }
  hash_key = "person_name"

  lifecycle {
    create_before_destroy = true
  }
}