# For ExpungeData Lambda
resource "aws_secretsmanager_secret" "expunge-data" {
  name = "${var.environment}-${var.customer}-${var.project_code}-expunge-data"
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "expunge-data" {
  secret_id = aws_secretsmanager_secret.expunge-data.id
  secret_string = file("../environment-files/secrets/expunge-data-secret.json")
}

# Authentication For API
resource "aws_secretsmanager_secret" "api-authentication" {
  name = "${var.environment}-${var.customer}-${var.project_code}-api-authentication"
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "api-authentication" {
  secret_id = aws_secretsmanager_secret.api-authentication.id
  secret_string = file("../environment-files/secrets/api-authentication.json")
}

# Parkland SFTP Authentication
resource "aws_secretsmanager_secret" "parkland-sftp" {
  name = "${var.environment}-${var.customer}-${var.project_code}-parkland-sftp"
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "parkland-sftp" {
  secret_id = aws_secretsmanager_secret.parkland-sftp.id
  secret_string = file("../environment-files/secrets/parkland-sftp.json")
}