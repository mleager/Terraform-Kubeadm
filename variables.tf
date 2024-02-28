variable "project" {
  default     = "k8s"
  type        = string
  description = "Project Name. Default is [ k8s ]"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS Region. Default is [ us-east-1 ]"
}

variable "instance_type" {
  default     = "t2.micro"
  type        = string
  description = "EC2 Instance Type. Default is [ t2.micro ]"
}

variable "user_data" {
  default     = "scripts/3-ubuntu.sh"
  type        = string
  description = "User Data script location. Default is [ scripts/3-ubuntu.sh ]"
}
