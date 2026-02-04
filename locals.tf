locals {
  # Generar nombres estandarizados para las claves KMS usando la clave del mapa
  # Eliminamos var.service del final para evitar redundancia
  kms_names = {
    for k, v in var.kms_config : k => "${var.client}-${var.project}-${var.environment}-kms-${k}"
  }
  
  # Generar nombres de alias para las claves KMS usando la clave del mapa
  kms_aliases = {
    for k, v in var.kms_config : k => "alias/${var.client}-${var.project}-${var.environment}-kms-${k}"
  }
}
