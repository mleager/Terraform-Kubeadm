module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.5.2"

  name = "${var.project}-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.101.0/24"] #"10.0.102.0/24"
  #private_subnets = ["10.0.1.0/24"]  #"10.0.2.0/24"

  map_public_ip_on_launch = true

  public_subnet_names = ["public-subnet-1a"]
  #private_subnet_names = ["private-subnet-1a"]

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  igw_tags = {
    Name = "igw"
  }

  nat_gateway_tags = {
    Name = "nat"
  }

  public_route_table_tags = {
    Name = "public-rt"
  }

  private_route_table_tags = {
    Name = "private-rt"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "${var.project}"
  }
}
