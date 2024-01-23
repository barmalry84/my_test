resource "aws_dynamodb_table" "people_info" {
  name         = "PeopleInfo"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "person_surname"
    type = "S"
  }
  hash_key = "person_surname"

  lifecycle {
    create_before_destroy = true
  }
}