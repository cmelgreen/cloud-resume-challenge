data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "cloud_resume_github_actions" {
  name = var.PROJECT_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
            StringEquals = {
                "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
            }
            StringLike = {
                "token.actions.githubusercontent.com:sub": "repo:${var.PROJECT_OWNER}/*:*"
            }
        }
      },
    ]
  })
}

locals {
  policy_names = {
    lambda        = "AWSLambda_FullAccess"
    iam           = "IAMFullAccess"
    apigateway    = "AmazonAPIGatewayAdministrator"
    s3            = "AmazonS3FullAccess"
    dynamodb      = "AmazonDynamoDBFullAccess"
    route53       = "AmazonRoute53FullAccess"
    cloudformation = "AWSCloudFormationFullAccess"
    cloudfront    = "CloudFrontFullAccess"
  }
}

data "aws_iam_policy" "policies" {
  for_each = local.policy_names
  name     = each.value
}

resource "aws_iam_role_policy_attachment" "cloud_resume" {
  for_each   = data.aws_iam_policy.policies
  role       = aws_iam_role.cloud_resume_github_actions.name
  policy_arn = each.value.arn
}

