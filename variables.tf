# La variable service ya no es necesaria ya que usamos la clave del mapa para identificar el servicio

variable "client" {
  description = "Nombre del cliente o empresa"
  type        = string
  
  validation {
    condition     = length(var.client) > 2 && length(var.client) <= 10
    error_message = "El nombre del cliente debe tener entre 3 y 10 caracteres."
  }
}

variable "environment" {
  description = "Entorno en el que se desplegarán los recursos (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  
  validation {
    condition     = length(var.project) > 2 && length(var.project) <= 15
    error_message = "El nombre del proyecto debe tener entre 3 y 15 caracteres."
  }
}

variable "kms_config" {
  description = "Configuración de claves KMS a crear"
  type = map(object({
    description         = string
    enable_key_rotation = bool
    statements = list(object({
      sid         = string
      actions     = list(string)
      resources   = list(string)
      effect      = string
      type        = string
      identifiers = list(string)
      condition = list(object({
        test     = string
        variable = string
        values   = list(string)
      }))
    }))
    additional_tags = optional(map(string), {})
  }))
  
  validation {
    condition = alltrue([
      for k, v in var.kms_config : 
      length(v.description) > 0
    ])
    error_message = "Todas las claves KMS deben tener una descripción."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.kms_config : 
      v.enable_key_rotation == true
    ])
    error_message = "La rotación de claves debe estar habilitada para todas las claves KMS por motivos de seguridad."
  }
}
