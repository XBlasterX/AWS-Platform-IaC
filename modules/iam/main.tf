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
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "ssm_operator" {
  statement {
    sid       = "StartSessionProjectInstances"
    effect    = "Allow"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Project"
      values   = ["AWS_Platform_IaC"]
    }
    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Environment"
      values   = ["lab"]
    }
  }
  statement {
    sid    = "AllowShellDocument"
    effect = "Allow"

    actions = ["ssm:StartSession"]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:document/SSM-SessionManagerRunShell"
    ]
  }
  statement {
    sid    = "ManageOwnSessions"
    effect = "Allow"

    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession",
      "ssmmessages:OpenDataChannel"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:session/&{aws:userid}-*"
    ]
  }
  statement {
    sid    = "DescribeInstancesAndSessions"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ssm:DescribeInstanceInformation",
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ssm_operator" {
  name        = "production-platform-ssm-operator"
  description = "Policy for SSM Operator"
  policy      = data.aws_iam_policy_document.ssm_operator.json
}

data "aws_iam_policy_document" "vpc_flow_logs_trust" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_trust.json
  name               = "vpc_flow_logs_role"
  tags = {
    "Name" = "vpc_flow_logs_role"
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name   = "vpc_flow_logs"
  role   = aws_iam_role.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_operator.json
}

data "aws_iam_policy_document" "vpc_flow_logs_operator" {
  statement {
    sid    = "DescribeLogGroups"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "DescribeLogStreams"
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams"
    ]
    resources = ["${var.flow_log_logs_group_arn}:*"]
  }
  statement {
    sid    = "PutLogEvents"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = ["${var.flow_log_logs_group_arn}:*"]
  }
  statement {
    sid    = "CreateLogStream"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream"
    ]
    resources = ["${var.flow_log_logs_group_arn}:*"]
  }
}
