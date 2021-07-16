##################
# Global variables
##################
# Instance Public Key - Public SSH key.
variable "instance_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

# Instance Key - The local copy of your key file.
variable "instance_key" {
  default = "~/.ssh/id_rsa"
}

###############
# AWS variables
###############
# AWS Region
variable "aws_region" {
  default = "us-east-1" # N. Virginia
}

# AWS Instance Type
variable "aws_instance_type" {
  default = "t2.medium"
}

# Key Name - The name of your key at AWS.
variable "key_name" {
  default = "bdausses_se"
}
