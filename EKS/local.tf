locals {
  name = "Globaltoye-${var.environment}"
  # var.cluster_name is for Terratest
  cluster_name = coalesce(var.cluster_name, local.name)
  region       = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, min(2, length(data.aws_availability_zones.available.names)))


  tags = {
    Name        = local.name
    Environment = var.environment
  }
}