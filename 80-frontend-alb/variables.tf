variable "project" {
    type = string
    default = "roboshop"
}

variable "environment" {
    type = string
    default = "dev"
}


variable "zone_id" {
    default = "Z04246872QFC8QNNXAS1U"
    type = string
}

variable "domain_name" {
    default = "devopsonline.online"
    type = string
}


variable "frontend_alb_tags" {
    type = map
    default = {}
}
