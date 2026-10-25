terraform {
  required_version = ">= 1.5.0"
}

# Deliberately invalid block to prove failure propagation in validation
resource "terraform_data" "broken" {
  invalid_attribute_name = undeclared_reference
}
