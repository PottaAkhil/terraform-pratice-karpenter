variable "cidr"{
  type        = string
}

variable "public_Subnet"{
  type        = list(string)
}

variable "private_Subnet"{
  type        = list(string)   
}

variable "routtable_cidr" {
  type =  string
  
}

variable "key_name" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "number" {
  type = number
}

variable "rules" {
  type = list(object({
    port = number
    proto = string
    cidr_blocks = list(string)
  }))
  }
variable "eks_cluster_name" {
  type = string
}

variable "resource_tags" {
  type = map(string)
}

variable "region" {
  type = string
  
}

# variable "addons" {
#   type = list(object({
#     name    = string
#     version = string
#   }))
#   }