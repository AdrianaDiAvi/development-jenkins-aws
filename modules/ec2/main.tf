resource "aws_instance" "jenkins_ec2" {
  ami           = "ami-xxxxxxxxxxxxxxxxx"
  instance_type = var.instance_type
  key_name      = var.key_pair
  # ... other instance configurations ...
}

output "jenkins_ec2_public_ip" {
  value = aws_instance.jenkins_ec2.public_ip
}
