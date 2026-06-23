variable "sns_topic_name" {}
variable "environment" {}
variable "region" {}
variable "project" {}
variable "owner" {}
variable "extra_tags" {
  type    = map(string)
  default = {} 
  }