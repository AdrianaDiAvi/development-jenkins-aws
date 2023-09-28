variable "AWS_ACCESS_KEY" {
  default = ""
}

variable "AWS_SECRET_KEY" {
  default = ""
}


variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
/*
variable "key_pair" {
  description = "EC2 key pair name"
  type        = string
  default     = "my-keypair"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "jenkins_version" {
  description = "Jenkins container version"
  type        = string
  default     = "latest"
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"
}

variable "efs_provisioned_throughput_in_mibps" {
  description = "EFS provisioned throughput in MiB/s"
  type        = number
  default     = 0
}
*/