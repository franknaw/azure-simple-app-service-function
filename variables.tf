variable "location" {
  description = "Azure location to deploy resources"
  type        = string
}

variable "plan_os_type" {
  description = "Service plan os type"
  type        = string
}

variable "plan_sku_name" {
  description = "Service plan sku name"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "app_name" {
  description = "Base app name"
  type        = string
}

variable "slot_1_name" {
  description = "Slot One name"
  type        = string
}

variable "product_name" {
  description = "Product name"
  type        = string
}

variable "tags" {
  description = "Map of tags"
  type        =  map(string)
}

variable "service_plan" {
  description = "Service plan"
}
