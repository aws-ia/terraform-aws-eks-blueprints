#-------------------------------
# Associates a certificate with an AWS Certificate Manager Private Certificate Authority (ACM PCA Certificate Authority).
# An ACM PCA Certificate Authority is unable to issue certificates until it has a certificate associated with it.
# A root level ACM PCA Certificate Authority is able to self-sign its own root certificate.
#-------------------------------

# # https://docs.aws.amazon.com/acm-pca/latest/userguide/pca-rbp.html

resource "aws_acmpca_certificate_authority" "this" {
  enabled = true 
  type = "ROOT"

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = var.custom_domain_name
      organization = var.organization
    }
  }

  permanent_deletion_time_in_days = 7

  tags = local.tags
}

resource "aws_acmpca_certificate" "this" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.this.arn
  certificate_signing_request = aws_acmpca_certificate_authority.this.certificate_signing_request
  signing_algorithm           = "SHA512WITHRSA"

  template_arn = "arn:aws:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = "YEARS"
    value = 10
  }
}

resource "aws_acmpca_certificate_authority_certificate" "this" {
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn

  certificate       = aws_acmpca_certificate.this.certificate
  certificate_chain = aws_acmpca_certificate.this.certificate_chain
}

#-------------------------------
# Create certificate in AWS Certificate Manager
#-------------------------------

resource "aws_acm_certificate" "private_domain_cert" {
  domain_name       = var.custom_domain_name
  #validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.custom_domain_name}"
  ]

  options {
    certificate_transparency_logging_preference = "DISABLED"
  }
  
  certificate_authority_arn = aws_acmpca_certificate_authority.this.arn

  tags = local.tags
}