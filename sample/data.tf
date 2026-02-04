###############################################################
# Data Sources
###############################################################

# Obtener información de la cuenta actual
data "aws_caller_identity" "current" {
  provider = aws.principal
}

# Obtener información de la región actual
data "aws_region" "current" {
  provider = aws.principal
}

# Ejemplo de cómo obtener información de roles IAM existentes
data "aws_iam_role" "example" {
  provider = aws.principal
  name     = "example-role"
  
  # Este bloque count hace que este data source sea opcional
  # Si el rol no existe, no fallará la ejecución
  count    = var.environment == "dev" ? 0 : 1
}
