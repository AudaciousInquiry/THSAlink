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

# Parkland EPIC Query Configuration
resource "aws_secretsmanager_secret" "parkland-epic-query" {
  name = "${var.environment}-${var.customer}-${var.project_code}-parkland-epic-query"
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "parkland-epic-query" {
  secret_id = aws_secretsmanager_secret.parkland-epic-query.id
  secret_string = file("../environment-files/secrets/parkland-epic-query.json")
}

# Parkland EPIC Authentication Configuration
resource "aws_secretsmanager_secret" "parkland-epic-auth" {
  name = "${var.environment}-${var.customer}-${var.project_code}-parkland-epic-auth"
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "parkland-epic-auth" {
  secret_id = aws_secretsmanager_secret.parkland-epic-auth.id
  secret_string = file("../environment-files/secrets/parkland-epic-authentication.json")
}

# Parkland Refresh Patient List
resource "aws_secretsmanager_secret" "parkland-refresh-patient-list" {
  name = "${var.environment}-${var.customer}-${var.project_code}-parkland-refresh-patient-list"
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "parkland-refresh-patient-list" {
  secret_id = aws_secretsmanager_secret.parkland-refresh-patient-list.id
  secret_string = file("../environment-files/secrets/parkland-refresh-patient-list.json")
}

# Generate Report
resource "aws_secretsmanager_secret" "generate-report" {
  name = "${var.environment}-${var.customer}-${var.project_code}-generate-report"
  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "generate-report" {
  secret_id = aws_secretsmanager_secret.generate-report.id
  secret_string = file("../environment-files/secrets/generate-report.json")
}