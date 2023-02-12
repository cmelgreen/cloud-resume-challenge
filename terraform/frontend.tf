provider "aws" {
  region = var.AWS_REGION
}

resource "aws_s3_bucket" "cloud_resume" {
  bucket = "${var.PROJECT_OWNER}-${var.PROJECT_NAME}"
}

data "aws_acm_certificate" "issued" {
  domain   = var.DOMAIN
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_distribution" "cloud_resume" {
  origin {
    origin_id           = aws_s3_bucket.cloud_resume.bucket
    domain_name  = aws_s3_bucket.cloud_resume.bucket_domain_name
  }

  default_root_object = var.DEFAULT_ROOT_OBJECT
  aliases             = ["${var.PROJECT_NAME}.${var.DOMAIN}"]

  enabled             = true
  is_ipv6_enabled     = true

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
    acm_certificate_arn            = data.aws_acm_certificate.issued.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2019"
    ssl_support_method             = "sni-only"
  }

}

data "aws_route53_zone" "domain" {
  name         = var.DOMAIN
}

resource "aws_route53_record" "cloud_resume_route53" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.PROJECT_NAME}.${var.DOMAIN}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.cloud_resume.domain_name]
}