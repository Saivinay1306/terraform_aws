resource "aws_vpc" "terravpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-${var.region}-${var.vpc_name}"
  }
}

resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.terravpc.default_route_table_id
  tags = merge(
    {
      Name = "${var.environment}-${var.region}-${var.vpc_name}-default-rt"
    }
  )
}

resource "aws_default_network_acl" "default_nacl" {
  default_network_acl_id = aws_vpc.terravpc.default_network_acl_id
  tags = merge(
    {
      Name = "${var.environment}-${var.region}-${var.vpc_name}-default-nacl"
    }
  )
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.terravpc.id
  tags = merge(
    {
      Name = "${var.environment}-${var.region}-${var.vpc_name}-default-sg"
    }
  )

}



#-------------------Flow Log------------------
resource "aws_flow_log" "terravpc_flowlog" {
  iam_role_arn    = aws_iam_role.example.arn
  log_destination = aws_cloudwatch_log_group.terracw_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.terravpc.id
  tags = {
    Name = "${var.environment}-${var.region}-${var.vpc_flowlog_name}"
  }
}

#-------------------CloudWatch Log Group------------------
resource "aws_cloudwatch_log_group" "terracw_log_group" {
  #checkov:skip=CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS"
  name              = "${var.environment}-${var.region}-${var.aws_cloudwatch_log_group_name}"
  retention_in_days = var.aws_cloudwatch_log_retention_days
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
    sid    = "AllowFlowLogsToWriteToLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.terracw_log_group.arn}:*"
    ]
  }

  statement {
    #checkov:skip=CKV_AWS_356: "Describe actions do not support resource-level permissions"
    #checkov:skip=CKV_AWS_111: "Describe actions do not support resource-level permissions"
    sid    = "AllowDescribeLogGroupsAndStreams"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role" "example" {
  name               = "${var.environment}-${var.region}-${var.vpc_flowlog_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_role_policy" "example" {
  name   = "${var.environment}-${var.region}-${var.vpc_flowlog_name}-policy"
  role   = aws_iam_role.example.id
  policy = data.aws_iam_policy_document.example.json
}
