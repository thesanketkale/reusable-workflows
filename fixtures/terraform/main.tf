terraform {
  required_version = ">= 1.5.0"
}

resource "terraform_data" "synthetic" {
  input = var.environment_name
}
