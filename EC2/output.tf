# output "web_instance" {
#     value = aws_instance.web.public_ip
# }

output "elb_dns_name" {
  value       = aws_lb.app-lb.dns_name
  description = "The domain name of the load balancer"
}
