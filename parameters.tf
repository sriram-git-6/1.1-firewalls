resource "aws_ssm_parameter" "vpn_sg_id" {
  name  = "/${var.project_name}/${var.env}/vpn_sg_id"
  type  = "String"
  value = module.vpn_sg.security_group_id
}

resource "aws_ssm_parameter" "mongodb_sg_id" {
  name  = "/${var.project_name}/${var.env}/mongoDB_sg_id"
  type  = "String"
  value = module.mongodb_sg.security_group_id
}

resource "aws_ssm_parameter" "catalogue_sg_id" {
  name  = "/${var.project_name}/${var.env}/catalogue_sg_id"
  type  = "String"
  value = module.catalogue_sg.security_group_id
}

resource "aws_ssm_parameter" "web_sg_id" {
  name  = "/${var.project_name}/${var.env}/web_sg_id"
  type  = "String"
  value = module.web_sg.security_group_id
}

resource "aws_ssm_parameter" "app_alb_sg_id" {
  name  = "/${var.project_name}/${var.env}/app_alb_sg_id"
  type  = "String"
  value = module.app_alb_sg.security_group_id
}

resource "aws_ssm_parameter" "web_alb_sg_id" {
  name  = "/${var.project_name}/${var.env}/web_alb_sg_id"
  type  = "String"
  value = module.web_alb_sg.security_group_id
}

resource "aws_ssm_parameter" "user_sg_id" {
  name  = "/${var.project_name}/${var.env}/user_sg_id"
  type  = "String"
  value = module.user_sg.security_group_id
}

resource "aws_ssm_parameter" "redis_sg_id" {
  name  = "/${var.project_name}/${var.env}/redis_sg_id"
  type  = "String"
  value = module.redis_sg.security_group_id
}

  