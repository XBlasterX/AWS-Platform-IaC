data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name               = "production-platform-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
  tags = {
    "Name" = "production-platform-ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "production-platform-ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm.name
  tags = {
    "Name" = "production-platform-ec2-ssm-instance-profile"
  }
}
