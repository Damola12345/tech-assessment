# Configured AWS Provider with Proper Credentials
# terraform aws provider
provider "aws" {
  region  = var.region
  profile = "terraform-user"
}

