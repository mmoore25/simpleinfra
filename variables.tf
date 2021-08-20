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
