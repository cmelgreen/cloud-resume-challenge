data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
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
          Federated = aws_iam_openid_connect_provider.github.arn
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

data "aws_iam_policy" "lambda_full_access" {
  name = "AWSLambda_FullAccess"
}

data "aws_iam_policy" "iam_full_access" {
  name = "IAMFullAccess"
}

data "aws_iam_policy" "apigateway_full_access" {
  name = "AmazonAPIGatewayAdministrator"
}

data "aws_iam_policy" "s3_full_access" {
  name = "AmazonS3FullAccess"
}

data "aws_iam_policy" "dynamodb_full_access" {
  name = "AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "route53_full_access" {
  name = "AmazonRoute53FullAccess"
}

data "aws_iam_policy" "cloudformation_full_access" {
  name = "AWSCloudFormationFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloud_resume_lambda" {
  role       = aws_iam_role.cloud_resume_github_actions.name
  policy_arn = data.aws_iam_policy.lambda_full_access.arn
}

resource "aws_iam_role_policy_attachment" "cloud_resume_iam" {
  role       = aws_iam_role.cloud_resume_github_actions.name
  policy_arn = data.aws_iam_policy.iam_full_access.arn
}

resource "aws_iam_role_policy_attachment" "cloud_resume_apigateway" {
  role       = aws_iam_role.cloud_resume_github_actions.name
  policy_arn = data.aws_iam_policy.apigateway_full_access.arn
}

resource "aws_iam_role_policy_attachment" "cloud_resume_s3" {
  role       = aws_iam_role.cloud_resume_github_actions.name
  policy_arn = data.aws_iam_policy.iam_full_access.arn
}

resource "aws_iam_role_policy_attachment" "cloud_resume_dynamodb" {
  role       = aws_iam_role.cloud_resume_github_actions.name
  policy_arn = data.aws_iam_policy.dynamodb_full_access.arn
}

resource "aws_iam_role_policy_attachment" "cloud_resume_route53" {
  role       = aws_iam_role.cloud_resume_github_actions.name
  policy_arn = data.aws_iam_policy.route53_full_access.arn
}

resource "aws_iam_role_policy_attachment" "cloud_resume_cloudformation" {
  role       = aws_iam_role.cloud_resume_github_actions.name
  policy_arn = data.aws_iam_policy.cloudformation_full_access
}