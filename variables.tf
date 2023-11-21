variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_name" {
  description = "Fullnode VPC"
  type        = string
  default     = "fullnode-vpc" # You can set a default value or remove this line
}

variable "subnet_01_name" {
  description = "Name for the first subnet"
  type        = string
  default     = "fullnode-subnet-01"
}

variable "subnet_02_name" {
  description = "Name for the second subnet"
  type        = string
  default     = "fullnode-subnet-02"
}


variable "subnet_01_az" {
  description = "Availability zone for the first subnet"
  type        = string
  default     = "ap-southeast-1a"
}

variable "subnet_02_az" {
  description = "Availability zone for the second subnet"
  type        = string
  default     = "ap-southeast-1b"
}

variable "ec2_instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "m5.8xlarge"
}

variable "ec2_disk_size" {
  description = "Size of the root disk in GB"
  type        = number
  default     = 200
}

variable "user_data_file" {
  description = "Path to the user data script file"
  type        = string
  default     = "script/pre-install.sh"
}

variable "namada_tag" {
  description = "Namada tag for the installation script"
  type        = string
  default     = "v0.23.2"
}

variable "cbft" {
  description = "CBFT version for the installation script"
  type        = string
  default     = "v0.37.2"
}

variable "namada_chain_id" {
  description = "Namada chain ID for the installation script"
  type        = string
  default     = "public-testnet-14.5d79b6958580"
}
