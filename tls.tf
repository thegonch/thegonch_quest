# tls.tf

resource "tls_private_key" "gonchquest" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_self_signed_cert" "gonchquest" {
  private_key_pem = tls_private_key.gonchquest.private_key_pem
  subject {
    common_name = "${var.domain}"
  }
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "key_agreement",
    "cert_signing",
    "crl_signing"
  ]
}

resource "aws_acm_certificate" "gonchquest" {
  private_key      = tls_private_key.gonchquest.private_key_pem
  certificate_body = tls_self_signed_cert.gonchquest.cert_pem
}

# resource "aws_route53_zone" "main" {
#   name         = "${var.domain}"
# }
# resource "aws_acm_certificate_validation" "default" {
#   certificate_arn = "${aws_acm_certificate.gonchquest.arn}"
#   #validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]



#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

#   # validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
# }

# resource "aws_route53_record" "cert_validation" {
#   zone_id = aws_route53_zone.main.zone_id
#   # name    = aws_acm_certificate.gonchquest.domain_validation_options.*.resource_record_name[0]
#   # type    = aws_acm_certificate.gonchquest.domain_validation_options.*.resource_record_type[0]
#   # records = ["${aws_acm_certificate.gonchquest.domain_validation_options.*.resource_record_value[0]}"]

#   for_each = {
#     for option in aws_acm_certificate.gonchquest.domain_validation_options : option.domain_name => {
#       name   = option.resource_record_name
#       record = option.resource_record_value
#       type   = option.resource_record_type
#     }
#   }
#   allow_overwrite = true
#   name    = each.value.name
#   records = [each.value.record]
#   ttl     = 60
#   type    = each.value.type
# }
