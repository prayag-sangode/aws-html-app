provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildRole"
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

# IAM Policy for CodeBuild
resource "aws_iam_policy" "codebuild_policy" {
  name        = "CodeBuildPolicy"
  description = "Policy for CodeBuild operations"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage"
        ],
        Resource = "arn:aws:ecr:us-east-1:123456789012:repository/repository-name" # Replace with your ECR repository ARN
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = "arn:aws:eks:us-east-1:058264559032:cluster/my-cluster" # Replace with your EKS cluster ARN
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::codepipeline-us-east-1-35331292553/MyHTMLAppPipeLine/*" # Replace with your S3 bucket ARN and path
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn  = aws_iam_policy.codebuild_policy.arn
}

# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for CodePipeline
resource "aws_iam_policy" "codepipeline_policy" {
  name        = "CodePipelinePolicy"
  description = "Policy for CodePipeline operations"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_full_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecr_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

# Outputs
output "codebuild_role_arn" {
  description = "The ARN of the CodeBuild role"
  value       = aws_iam_role.codebuild_role.arn
}

output "codebuild_policy_arn" {
  description = "The ARN of the CodeBuild policy"
  value       = aws_iam_policy.codebuild_policy.arn
}

output "codebuild_policy_name" {
  description = "The name of the CodeBuild policy"
  value       = aws_iam_policy.codebuild_policy.name
}

output "codepipeline_role_arn" {
  description = "The ARN of the CodePipeline role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_policy_arn" {
  description = "The ARN of the CodePipeline policy"
  value       = aws_iam_policy.codepipeline_policy.arn
}

output "codepipeline_policy_name" {
  description = "The name of the CodePipeline policy"
  value       = aws_iam_policy.codepipeline_policy.name
}

output "codepipeline_ecr_policy_arn" {
  description = "The ARN of the ECR policy for CodePipeline"
  value       = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

output "codepipeline_ecr_policy_name" {
  description = "The name of the ECR policy for CodePipeline"
  value       = "AmazonEC2ContainerRegistryPowerUser"
}

output "codepipeline_codebuild_policy_arn" {
  description = "The ARN of the CodeBuild Admin Access policy for CodePipeline"
  value       = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

output "codepipeline_codebuild_policy_name" {
  description = "The name of the CodeBuild Admin Access policy for CodePipeline"
  value       = "AWSCodeBuildAdminAccess"
}
