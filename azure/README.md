# Pre-requisites
* Resource group
* Virtual Network + Subnet
* ssh keypair

# Resources Created

* 1 Virtual Machine
  - Ubuntu 20.04 LTS
  - Standard_D8_v4  (configurable, min: 8 vcpu, 32GB memory)
  - 200GB OS Disk (configurable, min: 200GB)
  - (Optional) 1 static public IP
  - 1 Security Group (all ports tcp)
    - 22
    - 80
    - 443
    - 6443
    - 8800
    - 30902

