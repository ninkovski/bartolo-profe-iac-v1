variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "bartolo-profe-app"
}

variable "environment" {
  description = "Ambiente (dev, cert, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "centralus"
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
  default     = "bartolo-profe-rg"
}

variable "tags" {
  description = "Tags para todos los recursos"
  type        = map(string)
  default = {
    Project     = "bartolo-profe-app"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

