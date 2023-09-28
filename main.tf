resource "aws_instance" "example" {
  ami           = "ami-0f58f8a424b5e374a"
  instance_type = "t2.micro"
  tags = {
    Name = "MiEC2Prueba"
  }
}





/*module "ec2" {
  source          = "./modules/ec2"
  instance_type   = var.instance_type
  key_pair        = var.key_pair
}

module "alb" {
  source  = "./modules/alb"
  
}

module "s3" {
  source  = "./modules/s3"
  
}

module "efs" {
  source = "./modules/efs"
  
}

module "jenkins" {
  source              = "./modules/jenkins"
  instance_type       = var.instance_type
  key_pair            = var.key_pair
  jenkins_version     = var.jenkins_version
  efs_file_system_id  = module.efs.jenkins_efs_file_system_id
  
} */