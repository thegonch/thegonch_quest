# Create a self-signed certificate for the domain specified in the variables.tf file and upload it to ACM.

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