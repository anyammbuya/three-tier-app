#Create a role
#trust policy: which specifies who or what can assume the role

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2smms3"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns =[aws_iam_policy.ssm_policy.arn, aws_iam_policy.s3ROA.arn, aws_iam_policy.ec2ssm_logs.arn]
}

#get the policies

resource "aws_iam_policy" "ssm_policy" {
  name        = "ssmpolicy"
  description = "A policy for ec2 to access ssm"
  policy      = file("modules/json-policy/ec2-policy-4-ssm.json")
}

resource "aws_iam_policy" "s3ROA" {
  name        = "AmazonS3ReadOnlyAccess"
  description = "A policy for ec2 to possess readOnly access to s3"
  policy      = file("modules/json-policy/AmazonS3ReadOnlyAccess.json")
}

resource "aws_iam_policy" "ec2ssm_logs" {
  name        = "S3SSMLogging"
  description = "A policy to send ssm session encrypted logs to s3"
  policy      = file("modules/json-policy/ec2-session-policy-4-s3.json")
}

#Attach role to an instance profile

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_role.name
}
