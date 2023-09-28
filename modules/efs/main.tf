resource "aws_efs_file_system" "jenkins_efs" {
  creation_token               = "jenkins-efs"
  performance_mode             = var.efs_throughput_mode
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps
  # ... other EFS configurations ...
}

output "jenkins_efs_file_system_id" {
  value = aws_efs_file_system.jenkins_efs.id
}
