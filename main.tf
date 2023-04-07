provider "aws" {
  region = "us-east-1" 
  }
module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name = "my-eks-cluster2"
  
  vpc_subnets = ["subnet-0d529dd75a00ba93c", "subnet-06ae8c8f74c4269ce"] # replace with your desired subnets
  
  tags = {
    Terraform   = "true"
    Environment = "qa"
  }
}