resource "aws_acm_certificate" "thsa1_sanerproject_org_exp_2024" {
  private_key               = file("../certs/thsa1_sanerproject_org_expire2024/thsa1_sanerproject_org.private.pem")
  certificate_body          = file("../certs/thsa1_sanerproject_org_expire2024/thsa1_sanerproject_org.certificate.pem")
  certificate_chain         = file("../certs/thsa1_sanerproject_org_expire2024/thsa1_sanerproject_org.chain.pem")
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_acm_certificate" "thsa_sanerproject_org_exp_2024" {
  private_key               = file("../certs/thsa_sanerproject_org_expire2024/thsa_sanerproject_org.private.pem")
  certificate_body          = file("../certs/thsa_sanerproject_org_expire2024/thsa_sanerproject_org.certificate.pem")
  certificate_chain         = file("../certs/thsa_sanerproject_org_expire2024/thsa_sanerproject_org.chain.pem")
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}