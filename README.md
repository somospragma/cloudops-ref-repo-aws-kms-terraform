# Módulo Terraform: cloudops-ref-repo-aws-kms-terraform

Este módulo permite la creación y gestión de claves AWS KMS (Key Management Service) siguiendo las mejores prácticas de seguridad y los estándares de infraestructura como código. Facilita la implementación de claves KMS para diferentes servicios AWS con políticas de acceso personalizadas y el principio de privilegio mínimo.

Para ver el historial de cambios, consulta el [CHANGELOG.md](./CHANGELOG.md). Se recomienda fijar versiones específicas del módulo para garantizar la estabilidad de tu infraestructura.

## Diagrama de Arquitectura

```
┌─────────────────────────────────────┐
│                                     │
│            AWS Account              │
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │         AWS KMS Key         │    │
│  │                             │    │
│  │  ┌─────────────────────┐    │    │
│  │  │                     │    │    │
│  │  │   Key Policy        │    │    │
│  │  │                     │    │    │
│  │  └─────────────────────┘    │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │       KMS Alias             │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

## Características

✅ Creación de múltiples claves KMS con una sola configuración  
✅ Políticas de acceso personalizables con soporte para condiciones  
✅ Implementación del principio de privilegio mínimo  
✅ Rotación automática de claves habilitada por defecto  
✅ Nomenclatura estandarizada para claves y alias  
✅ Sistema de etiquetado completo y personalizable  
✅ Validaciones para garantizar configuraciones seguras  
✅ Soporte para múltiples servicios AWS (Secrets Manager, S3, RDS, etc.)  

## Estructura del Módulo

```
cloudops-ref-repo-aws-kms-terraform/
├── main.tf           # Recursos principales (aws_kms_key, aws_kms_alias)
├── variables.tf      # Definición de variables con validaciones
├── outputs.tf        # Salidas del módulo
├── locals.tf         # Transformaciones y cálculos locales
├── data.tf           # Data sources para políticas y otros recursos
├── providers.tf      # Configuración de proveedores
├── README.md         # Documentación principal
├── CHANGELOG.md      # Historial de cambios
└── sample/           # Ejemplos de implementación
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── providers.tf
    ├── data.tf
    ├── terraform.tfvars.sample
    └── README.md
```

## Implementación y Configuración

### Requisitos Técnicos

| Nombre | Versión |
|--------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.31.0 |

### Provider Configuration

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "principal"
}

module "kms" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-kms-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal
  }
  
  # Resto de la configuración...
}
```

### Configuración del Backend

Se recomienda utilizar un backend remoto para almacenar el estado de Terraform:

```hcl
terraform {
  backend "s3" {
    bucket         = "mi-bucket-terraform-state"
    key            = "kms/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Convenciones de nomenclatura

Las claves KMS y sus alias siguen esta convención de nomenclatura:

- Clave KMS: `{client}-{project}-{environment}-kms-{key_identifier}`
- Alias KMS: `alias/{client}-{project}-{environment}-kms-{key_identifier}`

Donde:
- `client`: Nombre del cliente o empresa (3-10 caracteres)
- `project`: Nombre del proyecto (3-15 caracteres)
- `environment`: Entorno (dev, qa, pdn)
- `key_identifier`: Identificador único de la clave (proporcionado en la configuración)

### Estrategia de Etiquetado

El módulo implementa un sistema de etiquetado en tres niveles:

1. **Etiquetas obligatorias**: Nombre generado automáticamente según la convención de nomenclatura
2. **Etiquetas específicas por clave**: Definidas en `additional_tags` para cada clave KMS
3. **Etiquetas comunes**: Aplicadas a todos los recursos

### Recursos Gestionados

| Nombre | Tipo | Descripción |
|--------|------|-------------|
| aws_kms_key | Recurso | Clave KMS con política personalizada y rotación automática |
| aws_kms_alias | Recurso | Alias para la clave KMS siguiendo la convención de nomenclatura |

### Parámetros de Entrada

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client"></a> [client](#input_client) | Nombre del cliente o empresa | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input_project) | Nombre del proyecto | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input_environment) | Entorno en el que se desplegarán los recursos (dev, qa, pdn) | `string` | n/a | yes |
| <a name="input_kms_config"></a> [kms_config](#input_kms_config) | Configuración de claves KMS a crear | `map(object({...}))` | n/a | yes |

### Estructura de Configuración

La variable `kms_config` tiene la siguiente estructura:

```hcl
variable "kms_config" {
  description = "Configuración de claves KMS a crear"
  type = map(object({
    description         = string  # Descripción de la clave KMS
    enable_key_rotation = bool    # Habilitar rotación automática de claves
    statements = list(object({
      sid         = string        # Identificador único de la declaración
      actions     = list(string)  # Acciones KMS permitidas
      resources   = list(string)  # Recursos a los que aplica la política
      effect      = string        # "Allow" o "Deny"
      type        = string        # Tipo de principal (AWS, Service, etc.)
      identifiers = list(string)  # ARNs o identificadores de principales
      condition = list(object({
        test     = string        # Operador de condición
        variable = string        # Variable de condición
        values   = list(string)  # Valores para la condición
      }))
    }))
    additional_tags = optional(map(string), {})  # Etiquetas específicas para esta clave
  }))
}
```

### Valores de Salida

| Name | Description |
|------|-------------|
| <a name="output_kms_info"></a> [kms_info](#output_kms_info) | Información detallada de todas las claves KMS creadas, incluyendo ID y ARN |
| <a name="output_kms_alias_info"></a> [kms_alias_info](#output_kms_alias_info) | Información detallada de todos los alias de KMS creados |
| <a name="output_kms_complete_info"></a> [kms_complete_info](#output_kms_complete_info) | Información completa de las claves KMS y sus alias, combinada en una estructura fácil de usar |

### Ejemplos de Uso

**Ejemplo básico:**

```hcl
module "kms" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-kms-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal
  }
  
  client      = "pragma"
  project     = "hefesto"
  environment = "dev"
  
  kms_config = {
    "sm" = {
      description         = "Key for Secrets Manager"
      enable_key_rotation = true
      statements = [
        {
          sid         = "AllowSecretsManagerService"
          actions     = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey*"]
          resources   = ["*"]
          effect      = "Allow"
          type        = "Service"
          identifiers = ["secretsmanager.amazonaws.com"]
          condition   = []
        }
      ]
      additional_tags = {
        "Service" = "SecretsManager"
      }
    }
  }
}
```

## Escenarios de Uso Comunes

### Clave KMS para Secrets Manager con privilegio mínimo

```hcl
kms_config = {
  "sm" = {
    description         = "Key for Secrets Manager with least privilege"
    enable_key_rotation = true
    statements = [
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
            values   = ["123456789012"]  # ID de tu cuenta AWS
          }
        ]
      }
    ]
    additional_tags = {
      "Service" = "SecretsManager",
      "SecurityLevel" = "High"
    }
  }
}
```

### Clave KMS para S3 con acceso a roles específicos

```hcl
kms_config = {
  "s3" = {
    description         = "Key for S3 buckets"
    enable_key_rotation = true
    statements = [
      {
        sid         = "AllowS3Service"
        actions     = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey*"]
        resources   = ["*"]
        effect      = "Allow"
        type        = "Service"
        identifiers = ["s3.amazonaws.com"]
        condition   = []
      },
      {
        sid         = "AllowRoleAccess"
        actions     = ["kms:Decrypt"]
        resources   = ["*"]
        effect      = "Allow"
        type        = "AWS"
        identifiers = ["arn:aws:iam::123456789012:role/S3AccessRole"]
        condition   = []
      }
    ]
    additional_tags = {
      "Service" = "S3",
      "DataType" = "Confidential"
    }
  }
}
```

## Consideraciones Operativas

### Rendimiento y Escalabilidad

- AWS KMS tiene un límite de solicitudes por segundo que varía según la región
- Para cargas de trabajo de alto rendimiento, considere utilizar la caché del lado del cliente
- El módulo admite la creación de múltiples claves KMS para diferentes servicios

### Limitaciones y Restricciones

- Las claves KMS no se pueden transferir entre regiones o cuentas AWS
- Una vez eliminada, una clave KMS no puede ser recuperada después del período de espera
- El tamaño máximo de una política de clave KMS es de 32 KB

### Costos y Optimización

- AWS KMS cobra por clave KMS y por operación criptográfica
- Considere agrupar recursos relacionados bajo la misma clave KMS para reducir costos
- La rotación automática de claves no genera costos adicionales

### Recomendaciones de Implementación

- Utilice claves KMS dedicadas para datos altamente sensibles
- Implemente el principio de privilegio mínimo en las políticas de claves
- Habilite CloudTrail para auditar el uso de las claves KMS
- Utilice condiciones en las políticas para restringir el acceso por cuenta, región o servicio

## Seguridad y Cumplimiento

### Consideraciones de seguridad

- El módulo habilita la rotación automática de claves por defecto
- Las políticas implementan el principio de privilegio mínimo
- Se recomienda utilizar condiciones para limitar el acceso a servicios específicos

### Análisis de Seguridad

Este módulo ha sido analizado con las siguientes herramientas:

- KICS (Keeping Infrastructure as Code Secure): Sin problemas críticos
- Checkov: Cumple con las mejores prácticas de seguridad para AWS KMS

### Mejores Prácticas Implementadas

- ✅ Rotación automática de claves habilitada por defecto
- ✅ Políticas de acceso basadas en el principio de privilegio mínimo
- ✅ Validaciones para garantizar configuraciones seguras
- ✅ Etiquetado completo para facilitar la auditoría y el seguimiento
- ✅ Nomenclatura estandarizada para facilitar la gestión

### Lista de Verificación de Cumplimiento

- ✅ NIST 800-53: SC-12, SC-13 (Gestión de claves criptográficas)
- ✅ ISO 27001: A.10.1.2 (Gestión de claves)
- ✅ PCI DSS: Requisito 3.5 (Proteger claves criptográficas)
- ✅ CIS AWS Foundations: 2.8 (Rotación de claves KMS)

## Observaciones

- Las claves KMS son específicas de la región. Si necesitas cifrar datos en múltiples regiones, deberás crear claves en cada región.
- Considera implementar una estrategia de respaldo para los datos cifrados con KMS.
- Para casos de uso avanzados, como ABAC (control de acceso basado en atributos), puedes utilizar condiciones más complejas en las políticas de claves.
