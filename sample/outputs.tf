# ###############################################################
# # Outputs
# ###############################################################

# # Información completa de las claves KMS
# output "kms_keys" {
#   description = "Información detallada de todas las claves KMS creadas"
#   value = {
#     for key_id, key_info in module.kms.kms_info : key_id => {
#       key_id  = key_info.key_id
#       key_arn = key_info.key_arn
#     }
#   }
# }

# # Información de los alias de KMS
# output "kms_aliases" {
#   description = "Información detallada de todos los alias de KMS creados"
#   value = {
#     for alias_id, alias_info in module.kms.kms_alias_info : alias_id => {
#       name          = alias_info.name
#       arn           = alias_info.arn
#       target_key_id = alias_info.target_key_id
#     }
#   }
# }

# # Ejemplo de cómo usar las claves KMS en otros recursos
# output "example_rds_encryption_config" {
#   description = "Ejemplo de configuración de cifrado para RDS usando la clave KMS creada"
#   value = {
#     kms_key_id = module.kms.kms_info["rds"].key_arn
#     storage_encrypted = true
#   }
# }

# output "example_s3_encryption_config" {
#   description = "Ejemplo de configuración de cifrado para S3 usando la clave KMS creada"
#   value = {
#     server_side_encryption = "aws:kms"
#     kms_master_key_id      = module.kms.kms_info["s3"].key_id
#   }
# }
