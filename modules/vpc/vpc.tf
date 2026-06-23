resource "aws_vpc" "terravpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "{var.environment}-{var.region}-{var.vpc_name}"
  }
}

#-------------------Flow Log------------------
resource "aws_flow_log" "terravpc_flowlog" {
  iam_role_arn    = aws_iam_role.example.arn
  log_destination = aws_cloudwatch_log_group.terracw_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.terravpc.id
  tags = {
    Name= "{var.environment}-{var.region}-{var.vpc_flowlog_name}"
  }
}

#-------------------CloudWatch Log Group------------------
resource "aws_cloudwatch_log_group" "terracw_log_group" {
  name = "{var.environment}-{var.region}-{var.aws_cloudwatch_log_group_name}"
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role" "example" {
  name               = "{var.environment}-{var.region}-{var.vpc_flowlog_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_role_policy" "example" {
  name   = "{var.environment}-{var.region}-{var.vpc_flowlog_name}-policy"
  role   = aws_iam_role.example.id
  policy = data.aws_iam_policy_document.example.json
}