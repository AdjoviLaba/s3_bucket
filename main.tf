
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


locals {
  cluster_name = "my-eks-cluster" # Replace with your desired cluster name
}

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role_policy_attachment.eks_cluster.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]

  vpc_config {
    subnet_ids = aws_subnet.private.*.id
  }

  depends_on = [
    aws_vpc.this,
    aws_subnet.private
  ]

  depends_on = [
    aws_eks_cluster_auth.this
  ]
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = aws_iam_policy.eks_cluster.arn
  roles      = [aws_iam_role.eks_cluster.name]
}

resource "aws_iam_role_policy_attachment" "eks_cluster_ro" {
  policy_arn = aws_iam_policy.eks_cluster_ro.arn
  roles      = [aws_iam_role.eks_cluster.name]
}

resource "aws_iam_role_policy_attachment" "eks_cluster_vpc" {
  policy_arn = aws_iam_policy.eks_cluster_vpc.arn
  roles      = [aws_iam_role.eks_cluster_vpc.name]
}

resource "aws_iam_policy_attachment" "eks_cluster_ingress_policy_attachment" {
  policy_arn = aws_iam_policy.eks_cluster_ingress.arn
  roles      = [aws_iam_role.eks_cluster.name]
}

resource "aws_iam_policy" "eks_cluster" {
  name_prefix = local.cluster_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ]

        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_cluster_ro" {
  name_prefix = local.cluster_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]

        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_cluster_vpc" {
  name_prefix = local.cluster_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets"
        ]

        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_cluster_ingress" {
  name_prefix = local.cluster_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateTags",
          "ec2:DescribeTags"
        ]

        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16" # Replace with your desired VPC CIDR block

  tags = {
    Name = local.cluster_name
  }
}

resource "aws_subnet" "private" {
  count = 2 # Create 2 subnets, one in each AZ

  cidr_block = "10.0.${count.index + 1}.0/24" # Replace with your desired subnet CIDR blocks
  vpc_id     = aws_vpc.this.id

  tags = {
    Name = "${local.cluster_name}-private-${count.index + 1}"
  }
}

resource "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name

  depends_on = [
    aws_eks_cluster.this
  ]
}

data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role_policy_attachment.eks_cluster.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]

  vpc_config {
    subnet_ids = aws_subnet.private.*.id
  }

  depends_on = [
    aws_vpc.this,
    aws_subnet.private
  ]

  depends_on = [
    aws_eks_cluster_auth.this
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_ro,
    aws_iam_role_policy_attachment.eks_cluster_vpc,
    aws_iam_policy_attachment.eks_cluster_ingress_policy_attachment
  ]

  depends_on = [
    aws_iam_policy.eks_cluster,
    aws_iam_policy.eks_cluster_ro,
    aws_iam_policy.eks_cluster_vpc,
    aws_iam_policy.eks_cluster_ingress
  ]
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority.0.data
}
