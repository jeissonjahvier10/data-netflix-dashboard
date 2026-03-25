variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "dashboard-pt-032026"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}

variable "data_bucket_name" {
  description = "Nombre de bucket de datos"
  type        = string
}

variable "frontend_bucket_name" {
  description = "Nombre del bucket de frontend"
  type        = string
}

variable "data_processor_zip_path" {
  description = "Ruta del zip de la lambda de procesamiento"
  type        = string
  default     = "../lambda/data_processor.zip"
}

variable "api_dashboard_zip_path" {
  description = "Ruta del zip de la lambda api"
  type        = string
  default     = "../lambda/api_dashboard.zip"
}

variable "csv_key" {
  description = "Ruta del csv en S3"
  type        = string
  default     = "input/netflix_user_behavior_dataset.csv"
}