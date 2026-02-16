variable "project_name" {
  type    = string
  default = "mon-projet-tf"
}

variable "instance_names" {
  type    = list(string)
  default = ["web-1", "web-2"]
}

variable "disk_type" {
  type    = string
  default = "gp3"
}

variable "common_tags" {
  type = map(string)
}