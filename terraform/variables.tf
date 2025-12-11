variable "aws_region" { default = "ap-south-1" }

variable "instance_type" { default = "t3.micro" }

variable "docker_repo" { type = string }

variable "image_tag" { type = string }

variable "db_name" { default = "strapi" }
variable "db_username" { default = "strapi" }
variable "db_password" { default = "Strapi@1234" }

variable "key_name" { default = "" }
variable "project" {default = "sandeep"}
