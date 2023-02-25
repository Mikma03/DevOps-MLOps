provider "aws" {
 region = "us-west-1"
}

resource "aws_iam_user" "terraform_pchrostek" {
  name = "terraform_pchrostek"
  tags = {
    Desctiption = "Terraform"
  }
}

resource "aws_iam_policy" "pchrostek_mypolicy" {
  name  = "pchrostek_mypolicy"

  policy = jsonencode({
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "ec2:DescribeInstances",
                        "ec2:DescribeInstanceTypes",
                        "ec2:DescribeRouteTables",
                        "ec2:DescribeSecurityGroups",
                        "ec2:DescribeSubnets",
                        "ec2:DescribeVolumes",
                        "ec2:DescribeVolumesModifications",
                        "ec2:DescribeVpcs",
                        "eks:DescribeCluster"
                    ],
                    "Resource": "*"
                }
            ]
        }

)
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.terraform_pchrostek.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_user_policy_attachment" "test-attach-2" {
  user       = aws_iam_user.terraform_pchrostek.name
  policy_arn = aws_iam_policy.pchrostek_mypolicy.arn
}

resource "aws_iam_user_policy" "pchrostek_mypolicy-2" {
  name  = "pchrostek_mypolicy-2"
  user = aws_iam_user.terraform_pchrostek.name

  policy = <<EOF
{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "ec2:DescribeInstances",
                        "ec2:DescribeInstanceTypes",
                        "ec2:DescribeRouteTables",
                        "ec2:DescribeSecurityGroups",
                        "ec2:DescribeSubnets",
                        "ec2:DescribeVolumes",
                        "ec2:DescribeVolumesModifications",
                        "ec2:DescribeVpcs",
                        "eks:DescribeCluster"
                    ],
                    "Resource": "*"
                }
            ]
        }
EOF
}