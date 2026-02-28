# Parcial 1: Arquitectura AWS con ECS Fargate, ALB y CI/CD 🐮

Este proyecto implementa una arquitectura completa en AWS utilizando **Terraform** para la infraestructura y **GitHub Actions** para el despliegue automatizado de una aplicación en **Vue.js**.

## Estructura del Proyecto

- **`.github/workflows/`**: Pipeline de CI/CD que automatiza el build de Docker y el despliegue en ECS.
- **`app/`**: Aplicación frontend en Vue 3 con temática de vacas 🐮, configurada para correr en el puerto **8000**.
- **`iac/`**: Código de Terraform modular para la infraestructura (VPC, ALB, ECS, ECR, IAM).
- **`ESTUDIO_INFRAESTRUCTURA.md`**: Guía detallada sobre los componentes de red y seguridad.
- **`ESTUDIO_DEVOPS_CICD.md`**: Guía detallada sobre el flujo de automatización y Docker.

## Requisitos Previos

1. AWS CLI configurado con credenciales.
2. Terraform instalado.
3. GitHub Secrets configurados (`AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY`).

## Pasos para el Despliegue

1. **Infraestructura**:
   ```bash
   cd iac
   terraform init
   terraform apply
   ```
2. **Aplicación**:
   Realiza un `git push` a la rama `main` para disparar el flujo de GitHub Actions. El pipeline construirá la imagen, la subirá al ECR `repo-bearozz` y actualizará el servicio ECS.

3. **Acceso**:
   Usa la URL del Load Balancer proporcionada por los `outputs` de Terraform para ver la aplicación en el puerto 80.

## Notas Técnicas

- **Puerto del Contenedor**: 8000 (mapeado desde el puerto 80 del ALB).
- **Seguridad**: Los contenedores corren en subredes privadas sin IP pública.
- **Actualización**: El despliegue usa `force-new-deployment` para garantizar que siempre se tome la imagen más reciente de ECR.

---
**Proyecto Bearozz - bearozz (Beatriz Rosado)**
