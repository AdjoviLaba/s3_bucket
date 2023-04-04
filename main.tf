
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

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_1a" {
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "subnet_1b" {
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_eks_cluster" "my_cluster" {
  name = "my-eks-cluster"
  role_arn = aws_iam_role_policy_attachment.eks_cluster.arn

  depends_on = [
    aws_subnet.subnet_1a,
    aws_subnet.subnet_1b
  ]

  vpc_config {
    subnet_ids = [
      aws_subnet.subnet_1a.id,
      aws_subnet.subnet_1b.id
    ]
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = aws_iam_policy.eks_cluster.arn
  roles      = [aws_iam_role.eks_cluster.name]
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}
data "aws_eks_cluster" "my_cluster" {
  name = aws_eks_cluster.my_cluster.name
}

resource "aws_iam_policy" "eks_cluster" {
  name = "eks-cluster-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:TagResource",
          "eks:UntagResource",
        ]
        Effect = "Allow"
        Resource = data.aws_eks_cluster.my_cluster.arn
      },
      {
        Action = [
          "eks:CreateFargateProfile",
          "eks:DeleteFargateProfile",
          "eks:DescribeFargateProfile",
          "eks:ListFargateProfiles",
          "eks:UpdateFargateProfile",
        ]
        Effect = "Allow"
        Resource = aws_eks_cluster.my_cluster.arn
      },
      {
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
        ]
        Effect = "Allow"
        Resource = aws_subnet.subnet_1a.arn
      },
      {
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
        ]
        Effect = "Allow"
        Resource = aws_subnet.subnet_1b.arn
      },
    ]
  })
}
