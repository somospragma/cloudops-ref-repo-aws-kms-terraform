# Ejemplo de implementación del módulo cloudops-ref-repo-aws-kms-terraform

Este ejemplo muestra cómo implementar el módulo de AWS KMS siguiendo las mejores prácticas y estándares definidos en las reglas de módulos de referencia. Se enfoca en la creación de una clave KMS para Secrets Manager con el principio de privilegio mínimo.

## Estructura de archivos

- `main.tf` - Configuración principal que llama al módulo KMS
- `providers.tf` - Configuración de proveedores AWS
- `variables.tf` - Definición de variables para el ejemplo
- `outputs.tf` - Salidas del ejemplo
- `data.tf` - Recursos de datos utilizados en el ejemplo
- `terraform.tfvars.sample` - Ejemplo de archivo de variables (renombrar a terraform.tfvars para usar)
- `terraform.tfvars` - Archivo de variables con valores específicos

## Requisitos previos

- Terraform v1.0.0 o superior
- AWS CLI configurado con credenciales válidas
- Permisos IAM para crear y gestionar recursos KMS
- Conocimiento básico de AWS KMS y políticas IAM

## Cómo usar este ejemplo

1. Clona el repositorio y navega al directorio del ejemplo:
   ```bash
   cd cloudops-ref-repo-aws-kms-terraform/sample
   ```

2. Copia el archivo de variables de ejemplo y personalízalo (si no existe ya):
   ```bash
   cp terraform.tfvars.sample terraform.tfvars
   # Edita terraform.tfvars con tus valores específicos
   ```

3. Inicializa Terraform:
   ```bash
   terraform init
   ```

4. Verifica el plan de Terraform:
   ```bash
   terraform plan
   ```

5. Aplica la configuración:
   ```bash
   terraform apply
   ```

6. Verifica los recursos creados:
   ```bash
   terraform output
   ```

## Escenarios incluidos

Este ejemplo demuestra el siguiente escenario:

### Clave KMS para Secrets Manager con privilegio mínimo

Este escenario implementa una clave KMS para Secrets Manager siguiendo el principio de privilegio mínimo:

- Permite que el servicio de Secrets Manager use la clave, pero solo en la cuenta específica
- Utiliza condiciones para restringir el acceso solo a la cuenta actual
- Implementa una política que sigue las mejores prácticas de seguridad

```hcl
kms_config = {
  "sm" = {
    description         = "Key for encrypting Secrets Manager secrets with least privilege"
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
```

## Flujos de trabajo recomendados

### Añadir acceso para roles específicos

Si necesitas permitir que roles específicos accedan a los secretos cifrados, puedes añadir una declaración adicional a la política:

```hcl
{
  sid         = "AllowAppRolesAccess"
  actions     = [
    "kms:Decrypt",
    "kms:DescribeKey"
  ]
  resources   = ["*"]
  effect      = "Allow"
  type        = "AWS"
  identifiers = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AppRole1",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AppRole2"
  ]
  condition   = []
}
```

### Añadir una nueva clave KMS para otro servicio

Para añadir una nueva clave KMS para otro servicio, simplemente agrega una nueva entrada al mapa `kms_config`:

```hcl
kms_config = {
  "sm" = {
    # Configuración existente para Secrets Manager...
  },
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
      "Service" = "S3",
      "DataType" = "Confidential"
    }
  }
}
```

## Integración con otros servicios AWS

### Uso con Secrets Manager

Para usar la clave KMS creada con Secrets Manager:

```hcl
resource "aws_secretsmanager_secret" "example" {
  name        = "${var.client}-${var.project}-${var.environment}-secret-example"
  description = "Example secret using the KMS key with least privilege"
  kms_key_id  = module.kms_sm.kms_info["sm"].key_arn
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = jsonencode({
    username = "app-user",
    password = "replace-with-secure-password"
  })
}
```

## Limpieza

Para eliminar todos los recursos creados por este ejemplo:

```bash
terraform destroy
```

> **Nota**: La eliminación de claves KMS puede tener implicaciones en los datos cifrados con esas claves. Asegúrate de que no hay datos importantes cifrados con estas claves antes de eliminarlas.
