locals {
    vpc_id = data.aws.aws_ssm_parameter.vpc_id.value
}