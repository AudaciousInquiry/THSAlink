resource "aws_ecrpublic_repository" "thsa-link-api" {
  repository_name = "thsa-link-api"

  catalog_data {
    description = "API Component of THSALink Project"
  }
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-consumer" {
  repository_name = "thsa-link-consumer"
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-cqf" {
  repository_name = "thsa-link-cqf"
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-web" {
  repository_name = "thsa-link-web"
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-datastore" {
  repository_name = "thsa-link-datastore"
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-cli-refresh-patient-list" {
  repository_name = "thsa-link-cli-refresh-patient-list"
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-cli-generate-and-submit" {
  repository_name = "thsa-link-cli-generate-and-submit"
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-cli-expunge-data" {
  repository_name = "thsa-link-cli-expunge-data"
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-cli-parkland-csv" {
  repository_name = "thsa-link-cli-parkland-csv"
  tags = {

    CreatedBy = "terraform"
  }
}

resource "aws_ecrpublic_repository" "thsa-link-keycloak" {
  repository_name = "thsa-link-keycloak"
  tags = {
    CreatedBy = "terraform"
  }
}