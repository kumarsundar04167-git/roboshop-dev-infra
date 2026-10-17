locals {
    common_name = "${var.project}-${var.environment}"
    common_tags = {
        project = "var.project"
        environment = "var.environment"
        terraform = "true"
}