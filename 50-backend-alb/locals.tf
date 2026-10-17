locals {
    ami_id = data.aws_ami.joindevops.id
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
    common_name = "${var.project}-${var.environment}"
    common_tags = {
        project = "${var.project}"
        environment = "${var.environment}"
        terraform = "true"
    }
}