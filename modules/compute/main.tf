data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_launch_template" "app" {
  image_id      = data.aws_ssm_parameter.al2023.value
  user_data     = filebase64("${path.module}/user_data.sh")
  instance_type = var.instance_type
  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }
  vpc_security_group_ids = [var.ec2_security_group_ids]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "production-platform-app"
    }
  }
}
