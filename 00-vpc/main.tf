module "vpc" {
    source = "git::https://github.com/kumarsundar04167-git/terraform-aws-vpc.git?ref=main"
    project = var.project
    environment = var.environment
    is_peering_required = false
}