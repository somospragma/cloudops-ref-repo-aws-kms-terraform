###############################################################
# Variables Globales
###############################################################
variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "La región debe tener un formato válido, por ejemplo: us-east-1, eu-west-1, etc."
  }
}

variable "profile" {
  description = "Perfil de AWS CLI a utilizar"
  type        = string
}

variable "environment" {
  description = "Entorno en el que se desplegarán los recursos (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "client" {
  description = "Nombre del cliente o empresa"
  type        = string
  
  validation {
    condition     = length(var.client) > 2 && length(var.client) <= 10
    error_message = "El nombre del cliente debe tener entre 3 y 10 caracteres."
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

# La variable service_name_kms ya no es necesaria ya que se eliminó del módulo

variable "common_tags" {
  description = "Etiquetas comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

###############################################################
# Variables específicas de KMS
###############################################################
variable "enable_key_rotation" {
  description = "Habilitar rotación automática de claves KMS"
  type        = bool
  default     = true
  
  validation {
    condition     = var.enable_key_rotation == true
    error_message = "La rotación de claves debe estar habilitada para cumplir con las mejores prácticas de seguridad."
  }
}