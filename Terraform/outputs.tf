output "strapi_url" {
  value = "http://${aws_instance.strapi.public_ip}"
}
