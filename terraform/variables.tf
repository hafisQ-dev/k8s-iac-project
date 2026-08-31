variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
variable "instance_type" {
  description = "instance processor type"
  type        = string
  default     = "t3.micro"
}
variable "key_name" {
  description = "aws ssh key"
  type        = string
  default     = "k8s-ssh-key"
}
variable "node_count" {
  description = "workers"
  type        = number
  default     = 2
}

