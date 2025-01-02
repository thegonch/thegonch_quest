# outputs.tf

# Used to determine a successful deployment with the DNS name of the ALB

output "alb_hostname" {
  value = "${aws_alb.main.dns_name}:3000"
}