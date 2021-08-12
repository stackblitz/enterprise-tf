variable "key_pair_name" {
  description = "The name of the aws key pair to use for VM admin login"
}

variable "create_public_ip" {
  type        = bool
  description = "(Optional) Set to true if a public IP address is desired"
  default     = false
}

variable "instance_type" {
  description = "(Optional) EC2 Instance type to install StackBlitz on. Must have at least 8 cores and 32GB memory"
  default     = "m5.2xlarge"
}

variable "private_ip" {
  description = "The private IP address for the VM. Must be within the address space covered by the subnet "
}

variable "prefix" {
  description = "A prefix to use before the name of all StackBlitz resources"
}


variable "region" {
  description = "The AWS Region that all StackBlitz resources will be created in"
}

variable "subnet_id" {
  description = "The ID of Subnet to use for StackBlitz resources"
  default     = "type"
}

variable "vpn_available" {
  type        = bool
  description = "(Optional) Set to false to expose admin ports over the public IP address. If true admin ports are only accessilbe via private IP."
  default     = true
}
