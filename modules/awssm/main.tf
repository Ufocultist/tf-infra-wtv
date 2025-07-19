resource "aws_secretsmanager_secret" "wtv_db" {
  name        = "/${var.name}/${var.env}/db"
  description = "Database credentials and app secret key for production environment"
  tags = {
    Environment = var.env
    App         = var.name
  }
}

resource "aws_secretsmanager_secret_version" "wtv_db_version" {
  secret_id     = aws_secretsmanager_secret.wtv_db.id
  secret_string = jsonencode({
    DB_USERNAME      = var.db_username
    DB_PASSWORD      = var.db_password
    DB_ROOT_PASSWORD = var.db_root_password
    DB_HOST          = var.db_host
    DB_PORT          = var.db_port
    DB_NAME          = var.db_name
    SECRET_KEY       = var.flask_secret
  })
}