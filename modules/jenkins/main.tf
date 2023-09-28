resource "aws_instance" "jenkins_instance" {
  ami                    = "ami-xxxxxxxxxxxxxxxxx"
  instance_type          = var.instance_type
  key_name               = var.key_pair
  user_data              = file("${path.module}/user_data.sh")
  # ... other instance configurations ...
}

output "jenkins_instance_id" {
  value = aws_instance.jenkins_instance.id
}
