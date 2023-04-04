
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "eks_subnet" {
  count = 2
  cidr_block = "10.0.${count.index + 1}.0/24"  # Specify different CIDR blocks for each subnet
  availability_zone = "us-east-1a" # Specify different AZs for each subnet
  vpc_id = aws_vpc.eks_vpc.id
  
}

resource "aws_security_group" "eks_security_group" {
  name_prefix = "eks"
  vpc_id = aws_vpc.eks_vpc.id
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "my_cluster" {
  name = "my-eks-cluster"
  role_arn = aws_iam_role_policy_attachment.eks_cluster.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
  ]
  vpc_config {
    subnet_ids = aws_subnet.subnet_1.*.id  # Use all subnet IDs from subnet_1
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_cluster.name
}
