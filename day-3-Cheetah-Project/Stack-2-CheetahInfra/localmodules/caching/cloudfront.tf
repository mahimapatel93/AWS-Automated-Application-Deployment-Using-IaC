resource "aws_cloudfront_distribution" "main" {
  comment = var.comment
  enabled = "true"

  origin {
    domain_name = var.alb_dns_name
    origin_id   = var.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "fe-web"
    viewer_protocol_policy = "allow-all"

    allowed_methods = var.default_behavior_allowed_methods
    cached_methods  = var.default_behavior_cached_methods
    compress        = true

    forwarded_values {
      query_string = false
      headers      = var.default_behavior_forwarded_values_header
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = var.env_name
    Name        = "cheetah-${var.env_name}-datastore-cf"
  }
}