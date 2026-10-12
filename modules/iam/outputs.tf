output "ec2_instance_profile_name" {
    value = aws_iam_instance_profile.ec2_ssm.name
    description = "Name of the EC2 instance profile for SSM"
}