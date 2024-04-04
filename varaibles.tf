variable "project_name" {
    default = "roboshop"
  
}

variable "common_tags" {
    default = {
        project = "ROBOSHOP"
        ENVIRONMENT = "DEV"
        TERRAFORM = "true"
        COMPONENT = "FIREWALLS"
    }
  }
  
variable "env" {
    default = "dev"
  
}

