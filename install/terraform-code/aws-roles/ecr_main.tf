# ecr_main.tf

# IAM Role for CodeBuild ECR
resource "aws_iam_role" "codebuild_ecr_role" {
  name = "CodeBuildECRRole"
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

# IAM Policy for ECR Access
resource "aws_iam_policy" "codebuild_ecr_policy" {
  name        = "CodeBuildECRAccessPolicy"
  description = "Policy for accessing ECR from CodeBuild"
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
        Resource = "arn:aws:ecr:us-east-1:123456789012:repository/repository-name"  # Replace with your ECR repository ARN
      }
    ]
  })
}

# Attach ECR Policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_ecr_policy_attachment" {
  role       = aws_iam_role.codebuild_ecr_role.name
  policy_arn  = aws_iam_policy.codebuild_ecr_policy.arn
}

# Attach Managed ECR Policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_ecr_managed_policy_attachment" {
  role       = aws_iam_role.codebuild_ecr_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# Outputs
output "codebuild_ecr_role_arn" {
  description = "The ARN of the CodeBuild role for ECR"
  value       = aws_iam_role.codebuild_ecr_role.arn
}

output "codebuild_ecr_policy_arn" {
  description = "The ARN of the ECR access policy for CodeBuild"
  value       = aws_iam_policy.codebuild_ecr_policy.arn
}
