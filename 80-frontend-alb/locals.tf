locals {
    ami_id = data.aws_ami.joindevops.id
    frontend_alb_sg_id = data.aws_ssm_parameter.frontend_alb_sg_id.value
    certificate_arn = data.aws_ssm_parameter.certificate_arn.value
    public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
    common_name = "${var.project}-${var.environment}"
    common_tags = {
        project = "${var.project}"
        environment = "${var.environment}"
        terraform = "true"
    }
}