variable "project" {
    type = string
    default = "roboshop"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "mongodb_tags" {
    type = map
    default = {}
}

variable "zone_id" {
    default = "Z04246872QFC8QNNXAS1U"
    type = string
}

variable "domain_name" {
    default = "devopsonline.online"
    type = string
}

variable "redis_tags" {
    type = map
    default = {}
}

variable "rabbitmq_tags" {
    type = map
    default = {}
}

variable "mysql_tags" {
    type = map
    default = {}
}

variable "mysql_root_password" {
    type = string
}