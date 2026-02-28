variable "aws_region" {
  description = "Región de AWS para desplegar los recursos"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto para prefijos/sufijos"
  default     = "bearozz"
}

variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC"
  default     = "10.0.0.0/16"
}

variable "container_port" {
  description = "Puerto en el que escucha el contenedor"
  default     = 8000
}

variable "container_image" {
  description = "URL de la imagen en ECR"
  default     = "235494782320.dkr.ecr.us-east-1.amazonaws.com/repo-bearozz:latest"
}
