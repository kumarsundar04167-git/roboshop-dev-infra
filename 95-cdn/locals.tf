locals {
    cachingOptmized = data.aws_cloudfront_cache_policy.cachingOptmized.id
    cachingDisabled = data.aws_cloudfront_cache_policy.cachingDisabled.id
    certificate_arn = data.aws_ssm_parameter.certificate_arn.value
    
    common_name = "${var.project}-${var.environment}"
    common_tags = {
        project = "${var.project}"
        environment = "${var.environment}"
        terraform = "true"
    }
}