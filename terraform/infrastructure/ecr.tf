resource "aws_ecrpublic_repository" "thsa-link-api" {
  repository_name = "thsa-link-api"
}

resource "aws_ecrpublic_repository" "thsa-link-consumer" {
  repository_name = "thsa-link-consumer"
}

resource "aws_ecrpublic_repository" "thsa-link-cqf" {
  repository_name = "thsa-link-cqf"
}

resource "aws_ecrpublic_repository" "thsa-link-web" {
  repository_name = "thsa-link-web"
}

resource "aws_ecrpublic_repository" "thsa-link-datastore" {
  repository_name = "thsa-link-datastore"
}

resource "aws_ecrpublic_repository" "thsa-link-cli-refresh-patient-list" {
  repository_name = "thsa-link-cli-refresh-patient-list"
}

resource "aws_ecrpublic_repository" "thsa-link-cli-generate-and-submit" {
  repository_name = "thsa-link-cli-generate-and-submit"
}

resource "aws_ecrpublic_repository" "thsa-link-cli-expunge-data" {
  repository_name = "thsa-link-cli-expunge-data"
}