###############################################################
# Outputs
###############################################################

# Información completa de las claves KMS
output "kms_keys" {
  description = "Información detallada de todas las claves KMS creadas"
  value = {
    for key_id, key_info in module.kms_sm.kms_info : key_id => {
      key_id  = key_info.key_id
      key_arn = key_info.key_arn
    }
  }
}

# Información de los alias de KMS
output "kms_aliases" {
  description = "Información detallada de todos los alias de KMS creados"
  value = {
    for alias_id, alias_info in module.kms_sm.kms_alias_info : alias_id => {
      name          = alias_info.name
      arn           = alias_info.arn
      target_key_id = alias_info.target_key_id
    }
  }
}

# Información completa combinada
output "kms_complete_info" {
  description = "Información completa de las claves KMS y sus alias"
  value       = module.kms_sm.kms_complete_info
}

# Output específico para uso con Secrets Manager
output "secrets_manager_kms_key_arn" {
  description = "ARN de la clave KMS para Secrets Manager"
  value       = module.kms_sm.kms_info["sm"].key_arn
}

output "secrets_manager_kms_key_id" {
  description = "ID de la clave KMS para Secrets Manager"
  value       = module.kms_sm.kms_info["sm"].key_id
}

# Ejemplo de cómo usar la clave KMS con Secrets Manager
output "example_secrets_manager_config" {
  description = "Ejemplo de configuración para usar con Secrets Manager"
  value = {
    kms_key_id = module.kms_sm.kms_info["sm"].key_arn
    description = "Use this KMS key ARN when creating Secrets Manager secrets"
  }
}
