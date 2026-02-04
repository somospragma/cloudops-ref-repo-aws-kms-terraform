############################################################################
# Local Transformations - PC-IAC-026
############################################################################

# Patrón de Transformación: terraform.tfvars → data.tf → locals.tf → main.tf

locals {
  # Prefijo de gobernanza
  governance_prefix = "${var.client}-${var.project}-${var.environment}"
  
  # En este sample, no hay transformaciones complejas necesarias
  # ya que el módulo KMS maneja la configuración directamente.
  # Este archivo existe para cumplir con PC-IAC-001 y mantener
  # consistencia con otros módulos de referencia.
  
  # Ejemplo de transformación si necesitáramos inyectar valores dinámicos:
  # kms_config_transformed = {
  #   for k, v in var.kms_config : k => merge(v, {
  #     # Aquí podrían ir transformaciones adicionales
  #   })
  # }
}
