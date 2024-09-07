# eks_main.tf

# IAM Role for CodeBuild EKS
resource "aws_iam_role" "codebuild_eks_role" {
  name = "CodeBuildEKSRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for EKS Access
resource "aws_iam_policy" "codebuild_eks_policy" {
  name        = "CodeBuildEKSAccessPolicy"
  description = "Policy for accessing EKS from CodeBuild"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeAddon",
          "eks:ListAddons",
          "eks:DescribeAddonVersions"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach EKS Policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_eks_policy_attachment" {
  role       = aws_iam_role.codebuild_eks_role.name
  policy_arn  = aws_iam_policy.codebuild_eks_policy.arn
}

# Outputs
output "codebuild_eks_role_arn" {
  description = "The ARN of the CodeBuild role for EKS"
  value       = aws_iam_role.codebuild_eks_role.arn
}

output "codebuild_eks_policy_arn" {
  description = "The ARN of the EKS access policy for CodeBuild"
  value       = aws_iam_policy.codebuild_eks_policy.arn
}
