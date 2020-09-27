variable "aws_region" {}

variable "env" {
  default = ""
}

variable "paas_name" {
  default = ""
}

variable "aws_profile" {}

variable "ssm_role_policy" {
  default = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

variable "ecs_full_access_policy" {
  default = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

variable "vpc_id" {
  default = ""
}

variable "s3_bucket" {
    default = ""
}

variable "public_subnet_id1" {
    default = ""
}

variable "public_subnet_id2" {
  default = ""
}

variable "private_subnet1" {
  default = ""
}

variable "private_subnet2" {
  default = ""
}

variable "kube_sg_id" {
    default = ""
}

variable "key_pair" {
    default = ""
}

variable "kube_worker_instance_type" {
  default = "t2.micro"
}

variable "kube_worker_ami" {
  default = "ami-0ac80df6eff0e70b5"
}

variable "worker_desired_capacity" {
  default = 2
}

variable "kube_worker_version" {
  default = "v0.0"
}