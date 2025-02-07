# **Módulo Terraform: cloudops-ref-repo-aws-kms-terraform**

## Descripción:

Este módulo permite la creación y gestión de claves KMS en AWS, facilitando la encriptación de datos y la administración de permisos.

KMS:

- Crear un KMS necesario para la encriptación de datos sensibles.
- Establecer políticas de acceso para controlar quién puede administrar y utilizar las claves.
- Asociar el KMS con servicios específicos como RDS.


Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo
El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-kms-terraform/
└── environments/dev
    ├── terraform.tfvars
├── .gitignore
├── .terraform.lock.hcl
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.
 
<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/kms/providers.tf
provider "aws" {
  alias = "alias01"
  # ... otras configuraciones del provider
}

sample/kms/main.tf
module "kms" {
  source = ""
  providers = {
    aws.project = aws.alias01
  }
  # ... resto de la configuración
}
```
## Uso del Módulo:

```hcl
module "kms" {
  source = ""
  
  providers = {
    aws.principal = aws.principal
    aws.secondary = aws.secondary
  }

  # Common configuration 
  profile     = "profile01"
  aws_region  = "us-east-1"
  environment = "dev"
  client      = "cliente01"
  project     = "proyecto01"
  common_tags = {
    environment   = "dev"
    project-name  = "proyecto01"
    cost-center   = "xxxxxx"
    owner         = "xxxxxx"
    area          = "xxxxxx"
    provisioned   = "xxxxxx"
    datatype      = "xxxxxx"
  }

  # Dynamodb configuration 
  kms_config [
    {
        description         = "xxxxxx"
        enable_key_rotation = "xxxxxx"
        statements = {
          sid         = "xxxxxx"
          actions     = "xxxxxx"
          resources   = "xxxxxx"
          effect      = "xxxxxx"
          type        = "xxxxxx"
          identifiers = "xxxxxx"
          condition = {
            test     = "xxxxxx"
            variable = "xxxxxx"
            values   = "xxxxxx"
          }
        }
        application_id = "xxxxxx"
      }
    ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_kms_grant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |


## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="description "></a> [description ](#input\_description_) | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| <a name="enable_key_rotation"></a> [enable_key_rotation](#input\_enable_key_rotation_) | (Optional, required to be enabled if rotation_period_in_days is specified) Specifies whether key rotation is enabled. | `bool` | n/a | yes |
| <a name="actions"></a> [actions](#input\_actions_) | Name of the hash key in the index; must be defined as an attribute in the resource. | `string` | "kms:*" | yes |
| <a name="resources"></a> [resources](#input\_resources_) | Name of the range key; must be defined. | `string` | * | yes |
| <a name="effect"></a> [effect](#input\_effect_) | Enable point-in-time recovery options. See below. | `string` | allow | yes |
| <a name="type"></a> [type](#input\_type_) | Required) Attribute type. Valid values are S (string), N (number), B (binary). | `string` | AWS | yes |
| <a name="test"></a> [test](#input\_ntest_) | (Required) Unique within a region name of the table. | `string` | n/a | yes |
| <a name="variable"></a> [variable](#input\_variable_) | (Required) Whether to enable point-in-time recovery. It can take 10 minutes to enable for new tables. If the point_in_time_recovery block is not provided. | `string` | n/a | no |
| <a name="values"></a> [values](#input\_values_) | (Optional, Forces new resource) ARN of the CMK that should be used for the AWS KMS encryption. This argument should only be used if the key is different from the default KMS-managed DynamoDB key, alias/aws/dynamodb. | `string` | n/a | yes |
| <a name="application_id"></a> [application_id](#input\_application_id_) | (Optional) Whether to propagate the global table's tags to a replica. Default is false. Changes to tags only move in one direction: from global (source) to replica. In other words, tag drift on a replica will not trigger an update. Tag or replica changes on the global table, whether from drift or configuration changes, are propagated to replicas. Changing from true to false on a subsequent apply means replica tags are left as they were, unmanaged, not deleted. | `string` | n/a | yes |
