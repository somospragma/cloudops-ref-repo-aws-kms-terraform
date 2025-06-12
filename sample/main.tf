################################################################
# Module KMS - Secrets Manager with Least Privilege
################################################################
module "kms_sm" {
  source = "../"
    
  # Configuración de providers
  providers = {
    aws.project = aws.principal
  }
  
  # Variables comunes
  client      = var.client
  environment = var.environment
  project     = var.project
  
  # Configuración de KMS usando mapas de objetos
  kms_config = {
    "sm" = {
      description         = "Key for encrypting Secrets Manager secrets with least privilege"
      enable_key_rotation = true
      statements = [
        # Permitir que el servicio de Secrets Manager use la clave, pero solo en esta cuenta
        {
          sid         = "AllowSecretsManagerServiceInAccount"
          actions     = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          resources   = ["*"]
          effect      = "Allow"
          type        = "Service"
          identifiers = ["secretsmanager.amazonaws.com"]
          condition   = [
            {
              test     = "StringEquals"
              variable = "aws:SourceAccount"
              values   = [data.aws_caller_identity.current.account_id]
            }
          ]
        }
      ]
      additional_tags = {
        "Service"       = "SecretsManager",
        "SecurityLevel" = "High",
        "DataType"      = "Confidential",
        "LeastPrivilege" = "True"
      }
    }
  }
}
