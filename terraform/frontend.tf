provider "aws" {
  region = var.AWS_REGION
}

resource "aws_s3_bucket" "cloud_resume" {
  bucket = "${var.PROJECT_OWNER}-${var.PROJECT_NAME}"
}

module "cloudfront_distribution" {
  source              = "terraform-aws-modules/cloudfront/aws"
  origin = {
    origin_id           = aws_s3_bucket.cloud_resume.bucket
    domain_name  = aws_s3_bucket.cloud_resume.bucket_domain_name
  }

  default_root_object = var.DEFAULT_ROOT_OBJECT
  aliases             = ["${var.PROJECT_NAME}.${var.DOMAIN}"]
}

data "aws_api_gateway_rest_api" "api" {
  name = var.PROJECT_NAME
}

data "aws_route53_zone" "domain" {
  name         = var.DOMAIN
}

resource "aws_route53_record" "cloud_resume_route53" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.PROJECT_NAME}.${var.DOMAIN}"
  type    = "CNAME"
  ttl     = "300"
  records = [module.cloudfront_distribution.cloudfront_distribution_domain_name]
}