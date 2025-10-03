//file gives EC2 instance permission through IAM roles and instance profiles specifically for the monitoring system

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "monitoring-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach the AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile (bridge between EC2 and IAM role)
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "monitoring-ssm-profile"
  role = aws_iam_role.ssm_role.name
}
resource "aws_iam_role" "mon_role" {
  name = "monitoring-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "cw_ro" {
  role       = aws_iam_role.mon_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
resource "aws_iam_instance_profile" "mon_profile" {
  name = "monitoring-ec2-profile"
  role = aws_iam_role.mon_role.name
}

