#############################################################################
# VARIABLES
#############################################################################
variable "tags" {
  description = "(Optional) A mapping of default tags to assign to the resource"
  type        = map(string)
  default     = null
}


variable "basename" {
  type    = string
}



variable "location" {
  type    = string
  default = "East US"
}

variable "dbserversku" {
  type = string
}


variable "connectwebappname" {
  type = string
}
variable "apiwebappname" {
  type = string
}

variable "adminwebappname" {
  type = string
}

variable "adminwebappname" {
  type = string
}

variable "identitywebappname" {
  type = string
}
variable "storageaccountname" {
  type = string
}

variable "storageaccounttier" {
  type = string
}

variable "appsvcplanname" {
  type = string
}

variable "aksname" {
  type = string
}


variable "dbservername" {
  type = string
}

variable "administrator_login" {
  type = string
}

variable "administrator_login_password" {
  type = string
}


variable "dbname" {
  type = string
}
