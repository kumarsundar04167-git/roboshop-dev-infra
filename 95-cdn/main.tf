resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = false
  comment             = "Main CDN Distribution"
  

 
  origin {
    domain_name              = "${var.project}-${var.environment}.${var.domain_name}"
    origin_id                = "${var.project}-${var.environment}.${var.domain_name}"
    

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      
      # Optional timeout extensions
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }
  aliases = ["${var.project}-cdn.${var.domain_name}"]

  # Default Cache Behavior
  default_cache_behavior {
    target_origin_id       = "${var.project}-${var.environment}.${var.domain_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id = local.cachingDisabled

    forwarded_values {
     query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }
  
   # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/media/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project}-${var.environment}.${var.domain_name}"
    cache_policy_id = local.cachingDisabled
    

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

   # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/videos/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project}-${var.environment}.${var.domain_name}"
    cache_policy_id = local.cachingDisabled
    

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Price Class (Restricts locations to minimize cost)
  price_class = "PriceClass_100"

  # Geo Restriction Rules
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Default SSL/TLS Settings
  viewer_certificate {
    acm_certificate_arn = local.certificate_arn
    ssl_support_method  = "sni-only"
  }

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
  
resource "aws_route53_record" "cloudfront" {
  
  zone_id  = var.zone_id
  name     = "{var.project}-cdn.${var.domain_name}"
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.roboshop.domain_name
    zone_id                = aws_cloudfront_distribution.roboshop.hosted_zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}
}