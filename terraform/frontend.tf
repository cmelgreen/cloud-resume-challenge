provider "aws" {
  region = var.AWS_REGION
}

resource "aws_s3_bucket" "cloud_resume" {
  bucket = "${var.PROJECT_OWNER}-${var.PROJECT_NAME}"

  acl    = "public-read"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.PROJECT_OWNER}-${var.PROJECT_NAME}/*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_website_configuration" "cloud_resume" {
  bucket = aws_s3_bucket.cloud_resume.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket" "cloud_resume_validation" {
  bucket = "cloud-resume.cmelgreen.com"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::cloud-resume.cmelgreen.com/*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_website_configuration" "cloud_resume_validation" {
  bucket = aws_s3_bucket.cloud_resume_validation.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

locals {
  frontend_uri = "${var.PROJECT_NAME}.${var.DOMAIN}"
  backend_uri  = "${var.PROJECT_NAME}-api.${var.DOMAIN}"
}

resource "aws_acm_certificate" "cloud_resume" {
  domain_name               = local.frontend_uri
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "cloud_resume" {
  origin {
    origin_id   = aws_s3_bucket.cloud_resume.bucket
    domain_name = aws_s3_bucket.cloud_resume.bucket_regional_domain_name
  }

  default_root_object = var.DEFAULT_ROOT_OBJECT

  enabled         = true
  is_ipv6_enabled = true

  aliases = [local.frontend_uri]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.cloud_resume.bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cloud_resume.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }

  depends_on =[
    aws_acm_certificate_validation.cloud_resume
  ]
}

data "aws_route53_zone" "domain" {
  name = var.DOMAIN
}

resource "aws_route53_record" "cloud_resume" {
  zone_id         = data.aws_route53_zone.domain.zone_id
  name            = local.frontend_uri
  allow_overwrite = true
  type            = "CNAME"
  ttl             = "300"

  alias {
    name                   = aws_cloudfront_distribution.cloud_resume.domain_name
    zone_id                = aws_cloudfront_distribution.cloud_resume.hosted_zone_id
    evaluate_target_health = false
  }

}
