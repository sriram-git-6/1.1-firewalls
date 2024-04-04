# VPN (which is in default vpc)--> public ALB--> WEB--> private ALB --> catalogue--> mongodb

# 1. create VPN security group
# 2. create mongodb security group
# 3. create catalogue security group
# 4. create web security group
# 5. create private ALB security group
# 6. create public ALB security group

# RULES:

# 1. mongodb_catalogue --> mongodb should accept tarffic from catalogue
# 2. mongodb_vpn --> mongodb should accept traffic from VPN

# 1. catalogue_Private ALB ---> catalogue should accept traffic from private ALB 
# 2. catalogue_vpn -----------> catalogue should accept tarffic from VPN

# 1. Private ALB_web ---> private ALB should accept traffic from web
# 2. private ALB_vpn ---> private ALB should accept traffic from VPN

# 1. web_public ALB ---> web should accept traffic from public ALB
# 2. web_vpn ----------> web should accept traffic from VPN

# 1. public ALB_internet ------>public ALB should accept the traffic from internet on port number 80.

# modules for creating the respective security groups
module "vpn_sg" {
    source = "../../terraform-sg-module"
    sg_name = "roboshop-vpn"
    description = "allowing all ports from my home ip"
    # sg_ingress_rules = var.sg_ingress_rules
    vpc_id = data.aws_vpc.default.id  
    project_name = var.project_name
    common_tags = merge(
        var.common_tags,
        {
            COMPONENT = "VPN",
            Name = "Roboshop-vpn"
        }
    )
  }

module "mongodb_sg" {
    source = "../../terraform-sg-module"
    sg_name = "mongodb"
    description = "allowing traffic"
    vpc_id = data.aws_ssm_parameter.vpc_id.value   
    project_name = var.project_name
    common_tags = merge(
        var.common_tags,
        {
          COMPONENT = "MongoDB",
          Name = "MongoDB"
        }
    )
  }

module "catalogue_sg" {
    source = "../../terraform-sg-module"
    sg_name = "catalogue"
    description = "allowing traffic"
    vpc_id = data.aws_ssm_parameter.vpc_id.value   
    project_name = var.project_name
    common_tags = merge(
        var.common_tags,
        {
          COMPONENT = "Catalogue",
          Name = "Catalogue"
        }
    )
  }
 
module "web_sg" {
    source = "../../terraform-sg-module"
    sg_name = "web"
    description = "allowing traffic"
    vpc_id = data.aws_ssm_parameter.vpc_id.value   
    project_name = var.project_name
    common_tags = merge(
        var.common_tags,
        {
          COMPONENT = "web"
        }
    )
  }

module "app_alb_sg" {
    source = "../../terraform-sg-module"
    sg_name = "app_alb"
    description = "allowing traffic"
    vpc_id = data.aws_ssm_parameter.vpc_id.value   
    project_name = var.project_name
    common_tags = merge(
        var.common_tags,
        {
          COMPONENT = "app",
          Name = "app_alb"
        }
    )
  }

module "web_alb_sg" {
    source = "../../terraform-sg-module"
    sg_name = "web_alb"
    description = "allowing traffic"
    vpc_id = data.aws_ssm_parameter.vpc_id.value   
    project_name = var.project_name
    common_tags = merge(
        var.common_tags,
        {
          COMPONENT = "web",
          Name = "web_alb"
        }
    )
  }

  module "redis_sg" {
    source = "../../terraform-sg-module"
    sg_name = "redis"
    description = "allowing traffic"
    vpc_id = data.aws_ssm_parameter.vpc_id.value   
    project_name = var.project_name
    common_tags = merge(
        var.common_tags,
        {
          COMPONENT = "redis",
          Name = "redis"
        }
    )
  }

 module "user_sg" {
    source = "../../terraform-sg-module"
    sg_name = "user"
    description = "allowing traffic"
    vpc_id = data.aws_ssm_parameter.vpc_id.value   
    project_name = var.project_name
    common_tags = merge(
        var.common_tags,
        {
          COMPONENT = "user",
          Name = "user"
        }
    )
  }




# rule for allowing the traffic from only my ip

resource "aws_security_group_rule" "vpn" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] # This security group should allow traffic only from my ip only. 
  security_group_id = module.vpn_sg.security_group_id
}

# This is allowing traffic from all catalogue instances to mongodb

resource "aws_security_group_rule" "mongodb_catalogue" {  # mongodb accepting connections from catalogue
  description = "allowing port number 27017 from catalogue"
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  source_security_group_id = module.catalogue_sg.security_group_id
  security_group_id = module.mongodb_sg.security_group_id
}

# This is allowing traffic from VPN on port no 22 to mongodb for troubleshooting purpose

resource "aws_security_group_rule" "mongodb_vpn" {  # mongodb accepting connections from vpn
  description = "allowing port number 22 from catalogue"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.mongodb_sg.security_group_id
}

# This is allowing traffic from all user instances to redis

resource "aws_security_group_rule" "redis_user" {  # redis accepting connections from user
  description = "allowing port number 6379 from user"
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  source_security_group_id = module.user_sg.security_group_id
  security_group_id = module.redis_sg.security_group_id
}

# This is allowing traffic from vpn instances to redis

resource "aws_security_group_rule" "redis_vpn" {  # redis accepting connections from vpn
  description = "allowing port number 22 from catalogue"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.redis_sg.security_group_id
}

# This is allowing traffic from app_alb to user

resource "aws_security_group_rule" "user_app_alb" {  # user accepting connections from app_alb
  description = "allowing port number 8080 from app_alb"
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.id
  security_group_id = module.user_sg.security_group_id
}

# This is allowing traffic from vpn to user

resource "aws_security_group_rule" "redis_vpn" {  # redis accepting connections from vpn
  description = "allowing port number 22 from catalogue"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.user_sg.security_group_id
}


# This is allowing traffic from vpn to catalogue

resource "aws_security_group_rule" "catalogue_VPN" {  
  description = "allowing port number 22 from VPN"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.catalogue_sg.security_group_id
}

# This is allowing traffic from private alb i;e app-alb to catalogue

resource "aws_security_group_rule" "catalogue_app_alb" {  
  description = "allowing port number 8080 from VPN"
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.app_alb_sg.security_group_id
  security_group_id = module.catalogue_sg.security_group_id
}

# This is allowing traffic from web to private ALB

resource "aws_security_group_rule" "app_alb_web" {  
  description = "allowing port number 80 from web"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_sg.security_group_id
  security_group_id = module.app_alb_sg.security_group_id
}

# This is allowing traffic from vpn to private ALB

resource "aws_security_group_rule" "app_alb_VPN" {  
  description = "allowing port number 22 from VPN"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.app_alb_sg.security_group_id
}

# This is allowing traffic from public ALB to web  

resource "aws_security_group_rule" "web_public_ALB" {  
  description = "allowing port number 80 from VPN"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.web_alb_sg.security_group_id
  security_group_id = module.web_sg.security_group_id
}

# This is allowing traffic from vpn to web

resource "aws_security_group_rule" "web_vpn" {  
  description = "allowing port number 80 from VPN"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.web_sg.security_group_id
}

# This is allowing traffic from vpn to web

resource "aws_security_group_rule" "web_vpn_ssh" {  
  description = "allowing port number 22 from VPN"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.security_group_id
  security_group_id = module.web_sg.security_group_id
}
# This is allowing traffic from internet to public ALB using http

resource "aws_security_group_rule" "web_ALB_internet" {  
  description = "allowing port number 80 from internet"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.security_group_id
}

# This is allowing traffic from internet to public ALB using https

resource "aws_security_group_rule" "web_ALB_internet_https" {  
  description = "allowing port number 443 from internet"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.security_group_id
}