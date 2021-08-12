variable "create_public_ip" {
  description = "True if a public IP should be provisioned; False otherwise"
  type        = bool
  default     = true
}

variable "location" {
  description = "The Azure Region in which all StackBlitz resources should be created."
}

variable "prefix" {
  description = "The name prefix which will be used for all StackBlitz resources"
}

variable "public_key_path" {
  description = "the path of the public key to use for the admin user"
}

variable "resource_group" {
  description = "The name of the resource group to contain StackBlitz resources"
}

variable "subnet_opts" {
  type        = map(string)
  description = "Identifies the subnet that StackBlitz resources will be created in. All values are required."
  default = {
    name                 = "my-subnet"
    virtual_network_name = "my-vnet"
    resource_group_name  = "my-resource-group"
  }
}

variable "vm_size" {
  description = "The VM size to use. Must have at least 8 cores and 32GB memory"
  default     = "Standard_D8_v4"
}

variable "vm_disk_size" {
  type        = number
  description = "the size of the VM's OS (root) disk in GB. Must be at least 200"
  default     = 200
}

variable "vpn_available" {
  type        = bool
  description = "Set True if a VPN connection into the VM's subnet is available. When True, traffic to admin ports is only allowed via the VM's private IP."
  default     = true
}




