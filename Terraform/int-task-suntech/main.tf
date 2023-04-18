data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

locals {
  AMICondition = var.ami_id == ""
  WindowsAMI = var.platform_type == "Windows"
  UbuntuAMI = var.platform_type == "Linux"
  UseCloudStore = var.config_store_type == "CloudStore"
  WebadaptorCondition = var.server_webadaptor_name == ""
  ELBDNSNameCondition = !var.elbdns_name == ""
  stack_name = "infra-yaml-format"
  stack_id = uuidv5("dns", "infra-yaml-format")
}

variable platform_type {
  description = "Choose the platform type. Supported platform types are Windows and Linux. For supported operating systems refer to https://enterprise.arcgis.com/en/server/latest/cloud/amazon/enterprise-aws-supported-os.htm."
  type = string
}

variable ami_id {
  description = "If you are not sure which AMI to use, leave this field empty and the template will use the latest AMI ID for Windows Server 2019 or Ubuntu Server 18.04 LTS based on the platform type you selected. If you prefer to use AMI of your choice, then you can provide an EC2 instance AMI id in this format 'ami-xxxxxxx'. If you have stored AMI ID in AWS SSM Parameter store, then provide name in this format."
  type = string
}

variable keypair_name {
  description = "Choose an EC2 KeyPair to allow remote access to the EC2 instances."
  type = string
}

variable vpc_id {
  description = "Choose a VPC ID. Note: All ArcGIS Enterprise components that are part of same deployment must be deployed in the same VPC."
  type = string
}

variable subnet1 {
  description = "Choose a subnet ID. The subnet ID that you select must be within the VPC you have selected above."
  type = string
}

variable subnet2 {
  description = "Choose a second subnet ID. This must be a different subnet ID than you used for Subnet ID 1. The subnet Id that you select must be within the VPC you have selected above."
  type = string
}

variable site_domain {
  description = "Provide the fully qualified domain name for the ArcGIS Server site. The domain name must already exist and be resolvable. For example, test.abc.com. Contact your IT administrator if you are not sure what domain name to use."
  type = string
}

variable elbdns_name {
  description = "To use an elastic load balancer (ELB) with the deployment, provide the value for an application or classic ELB DNS Name. This ELB must already exist. If you do not want to use an ELB or want to configure it by yourself later, then leave this field empty. You can get the ELB DNS name by navigating to the Load Balancers section of the EC2 service within the AWS Management Console or, if you used an Esri CloudFormation template to create the ELB, you can get it from that template's output parameters. Valid ELB DNS name must end with '.elb.amazonaws.com'."
  type = string
}

variable server_instances {
  description = "Provide the number of EC2 instances in cluster. The default is 2. The maximum is 10. The minimum is 1."
  type = string
  default = 2
}

variable instance_type {
  description = "Choose an EC2 instance type. The default is m5.2xlarge."
  type = string
  default = "m5.2xlarge"
}

variable instance_drive_size {
  description = "Provide size of the root drive in GB. The default is 100 GB. Minimum is 100 GB. Maximum is 1024 GB."
  type = string
  default = 100
}

variable deployment_bucket {
  description = "Provide the name of the AWS S3 bucket that contains your software license files and SSL certificates. This bucket must already exist and contain the license file and SSL certificate for your deployment. You must be the owner of the bucket and it must reside in the same account as your deployment."
  type = string
}

variable server_license_file_key_name {
  description = "Provide the ArcGIS Server authorization file object key name. You must upload the license file ('.ecp' or '.prvc' file) to the deployment bucket before launching this stack. You can get the file object key name by navigating to the file within the deployment bucket in AWS S3 console. For example, 'server.prvc' or 'resources/licenses/server/server.prvc'."
  type = string
}

variable arcgis_user_password {
  description = "This password is only required if you deploy on Windows. Enter a password for the 'arcgis' user. You can either enter a plain text password or the ARN of your secret ID from AWS Secret Manager. It's a best practice to manage your passwords/secrets through AWS Secret Manager. Refer to Microsoft Windows documentation for password policies."
  type = string
}

variable siteadmin_user_name {
  description = "Provide a user name for the initial ArcGIS Server site administrator. The name must be 6 or more alphanumeric or underscore (_) characters and must start with a letter."
  type = string
  default = "siteadmin"
}

variable siteadmin_user_password {
  description = "Provide a password for the ArcGIS Server site administrator. You can either type a plain text password or the ARN of your secret ID from AWS Secret Manager. The password must be 8 or more alphanumeric characters and can contain underscore (_), at ('@'), or dot (.) characters. It's a best practice to manage your passwords/secrets through AWS Secret Manager."
  type = string
}

variable config_store_type {
  description = "Choose the ArcGIS Server configuration store type. The default is 'FileSystem'."
  type = string
  default = "FileSystem"
}

variable fileserver_instance_type {
  description = "Choose an EC2 instance type. Even if you selected a configuration store type of 'CloudStore', a seperate file server is still created to host ArcGIS Server shared directories. The default instance type is m5.2xlarge."
  type = string
  default = "m5.2xlarge"
}

variable fileserver_instance_drive_size {
  description = "The size of the root drive in GB. The default is 200 GB. Minimum is 100 GB. Maximum is 1024 GB."
  type = string
  default = 200
}

variable server_webadaptor_name {
  description = "If you want to use an ArcGIS Web Adaptor with the ArcGIS Server site, type a web adaptor name. Access to the ArcGIS Server site will be through a URL in the format 'https://<fully qualified domain name>/<web adaptor name>'. The name must begin with a letter and contain only alphanumeric characters. Leave this field empty if you do not want to use a web adaptor, and URLs for the site will be in the format 'https://<fully qualified domain name>/arcgis'.  It must begin with a letter and contain only alphanumeric characters."
  type = string
}

variable ssl_certificate_file_key_name {
  description = "If you include a web adaptor with the ArcGIS Server site, you can provide an SSL certificate from a certifying authority (.pfx file). If you are providing it, then you must upload the certificate to the deployment bucket before launching this stack. If you use a web adaptor and leave this field empty, a autogenerated self-signed certificate will be used with the web adpator. You can get the file object key name by navigating to the file within the deployment bucket in AWS S3 console. For example, 'domainname.pfx' or 'resources/sslcerts/domainname.pfx'."
  type = string
}

variable ssl_certificate_password {
  description = "If you include a web adaptor with the ArcGIS Server site and use an SSL certificate from a certifying authority, either type a plain text password or ARN of your secret ID from AWS Secret Manager."
  type = string
}

resource "aws_inspector_resource_group" "deployment_logs" {
  tags = {
    Name = "ArcGIS Enterprise Deployment Logs"
  }
}

resource "aws_iam_role" "arc_gis_enterprise_iam_role" {
  assume_role_policy = {
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "ssm.amazonaws.com",
            "lambda.amazonaws.com",
            "events.amazonaws.com"
          ]
        }
      }
    ]
    Version = "2012-10-17"
  }
  path = "/"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "Resource"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
}

resource "aws_iam_policy" "arc_gis_enterprise_iam_policy" {
  policy = {
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeLifecycleHooks",
          "autoscaling:DescribeLifecycleHookTypes",
          "autoscaling:DescribeLoadBalancers",
          "autoscaling:DescribeLoadBalancerTargetGroups",
          "autoscaling:DescribeTags",
          "autoscaling:AttachInstances",
          "autoscaling:AttachLoadBalancers",
          "autoscaling:AttachLoadBalancerTargetGroups",
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:DeleteLifecycleHook",
          "autoscaling:DetachInstances",
          "autoscaling:DetachLoadBalancers",
          "autoscaling:DetachLoadBalancerTargetGroups",
          "autoscaling:PutLifecycleHook",
          "autoscaling:UpdateAutoScalingGroup"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackResources",
          "cloudformation:DescribeStackResource",
          "cloudformation:DescribeStackEvents",
          "cloudformation:SignalResource"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "dynamodb:ListTables",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:GetRecords",
          "dynamodb:Query",
          "dynamodb:CreateTable",
          "dynamodb:DeleteItem",
          "dynamodb:DeleteTable",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:UpdateTable"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:CreateImage",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeAddresses",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeRegions",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:ModifyInstanceMetadataOptions",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:SendReply"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "elasticloadbalancing:ConfigureHealthCheck",
          "elasticloadbalancing:CreateLoadBalancerListeners",
          "elasticloadbalancing:CreateLoadBalancerPolicy",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteLoadBalancerListeners",
          "elasticloadbalancing:DeleteLoadBalancerPolicy",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancerPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:SetLoadBalancerListenerSSLCertificate",
          "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
          "elasticloadbalancing:SetRulePriorities"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "events:ListRules",
          "events:ListTargetsByRule",
          "events:DescribeRule",
          "events:PutRule",
          "events:DeleteRule",
          "events:DisableRule",
          "events:EnableRule",
          "events:PutEvents",
          "events:PutTargets",
          "events:RemoveTargets"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = "iam:PassRole"
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutMetricFilter"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetObject",
          "s3:DeleteObjectTagging",
          "s3:PutBucketTagging",
          "s3:PutObjectTagging",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = "secretsmanager:GetSecretValue"
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:DescribeAssociation",
          "ssm:DescribeDocument",
          "ssm:DescribeInstanceInformation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:PutConfigurePackageResult",
          "ssm:DeleteAssociation",
          "ssm:PutComplianceItems",
          "ssm:PutInventory",
          "ssm:SendCommand",
          "ssm:StartAutomationExecution",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  }
  name = "ArcGISEnterpriseIAMPolicy"
  document_type = "Automation"
}

resource "aws_ssm_document" "validate_input_automation" {
  content = {
    schemaVersion = "0.3"
    description = "Validates the input prameter for ArcGIS Enterprise and ArcGIS Server stacks."
    assumeRole = "{{ AutomationAssumeRole }}"
    parameters = {
      AutomationAssumeRole = {
        type = "String"
        description = "(Required) The ARN of the role that allows Automation to perform the actions on your behalf."
      }
      PlatformType = {
        type = "String"
        description = "(Required) Platform Type."
        allowedValues = [
          "Windows",
          "Linux"
        ]
      }
      VPCId = {
        type = "String"
        description = "(Optional) VPC Id."
        default = ""
      }
      Subnet1Id = {
        type = "String"
        description = "(Optional) Subnet1 Id."
        default = ""
      }
      Subnet2Id = {
        type = "String"
        description = "(Optional) Subnet2 Id."
        default = ""
      }
      AMIId = {
        type = "String"
        description = "(Optional) AMI Id."
        default = ""
      }
      EIPAllocationId = {
        type = "String"
        description = "(Optional) EIP Allocation Id."
        default = ""
      }
      ELBDNSName = {
        type = "String"
        description = "(Optional) ELB DNS Name."
        default = ""
      }
      InputELBType = {
        type = "String"
        description = "(Optional) ELB Type."
        default = ""
      }
      DeploymentBucketName = {
        type = "String"
        description = "(Optional) Deployment Bucket Name."
        default = ""
      }
      PortalLicenseFile = {
        type = "String"
        description = "(Optional) Portal License File."
        default = ""
      }
      ServerLicenseFile = {
        type = "String"
        description = "(Optional) Server License File."
        default = ""
      }
      SSLCertificateFile = {
        type = "String"
        description = "(Optional) SSL Certificate File."
        default = ""
      }
      SiteadminPasswordValue = {
        type = "String"
        description = "(Optional) Site Admin Password Value."
        default = ""
      }
      ArcGISUserPasswordValue = {
        type = "String"
        description = "(Optional) ArcGIS User Password Value."
        default = ""
      }
      SSLCertificatePasswordValue = {
        type = "String"
        description = "(Optional) SSL Certificate Password Value."
        default = ""
      }
      DeploymentLogs = {
        type = "String"
        description = "(Required) AWS CloudWatch log group name."
      }
      StackName = {
        type = "String"
        description = "(Required) AWS CloudFormation stack name."
      }
      WaitCondition = {
        type = "String"
        description = "(Required) Wait condition for CloudFormation stack."
      }
    }
    mainSteps = [
      {
        name = "ValidateInputParameters"
        action = "aws:executeScript"
        isEnd = True
        inputs = {
          Runtime = "PowerShell Core 6.0"
          InputPayload = {
            StackName = "{{StackName}}"
            RegionId = "{{global:REGION}}"
            VPCId = "{{VPCId}}"
            Subnet1Id = "{{Subnet1Id}}"
            Subnet2Id = "{{Subnet2Id}}"
            PlatformType = "{{PlatformType}}"
            AMIId = "{{AMIId}}"
            EIPAllocationId = "{{EIPAllocationId}}"
            ELBDNSName = "{{ELBDNSName}}"
            InputELBType = "{{InputELBType}}"
            DeploymentBucketName = "{{DeploymentBucketName}}"
            PortalLicenseFile = "{{PortalLicenseFile}}"
            ServerLicenseFile = "{{ServerLicenseFile}}"
            SSLCertificateFile = "{{SSLCertificateFile}}"
            SiteadminPasswordValue = "{{SiteadminPasswordValue}}"
            ArcGISUserPasswordValue = "{{ArcGISUserPasswordValue}}"
            SSLCertificatePasswordValue = "{{SSLCertificatePasswordValue}}"
            WaitCondition = "{{WaitCondition}}"
            ActionName = "ValidateInputParameters"
            LogGroupName = "{{DeploymentLogs}}"
          }
        }
      }
    ]
  }
  document_type = "Automation"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "ValidateInputAutomation"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
}

resource "aws_cloudformation_stack" "validate_input_wait_condition" {}

resource "aws_ssm_association" "validate_input_association" {
  name = aws_ssm_document.validate_input_automation.created_date
  parameters = {
    AutomationAssumeRole = [
      aws_iam_role.arc_gis_enterprise_iam_role.arn
    ]
    PlatformType = [
      var.platform_type
    ]
    VPCId = [
      var.vpc_id
    ]
    Subnet1Id = [
      var.subnet1
    ]
    Subnet2Id = [
      var.subnet2
    ]
    AMIId = [
      var.ami_id
    ]
    EIPAllocationId = [
      ""
    ]
    ELBDNSName = [
      var.elbdns_name
    ]
    InputELBType = [
      "application"
    ]
    DeploymentBucketName = [
      var.deployment_bucket
    ]
    PortalLicenseFile = [
      ""
    ]
    ServerLicenseFile = [
      var.server_license_file_key_name
    ]
    SSLCertificateFile = [
      var.ssl_certificate_file_key_name
    ]
    SiteadminPasswordValue = [
      var.siteadmin_user_password
    ]
    ArcGISUserPasswordValue = [
      var.arcgis_user_password
    ]
    SSLCertificatePasswordValue = [
      var.ssl_certificate_password
    ]
    DeploymentLogs = [
      aws_inspector_resource_group.deployment_logs.arn
    ]
    StackName = [
      local.stack_name
    ]
    WaitCondition = [
      "ValidateInputWaitCondition"
    ]
  }
}

resource "aws_lambda_function" "stop_stack_function" {
  code_signing_config_arn = {
    ZipFile = ""
  }
  role = aws_iam_role.arc_gis_enterprise_iam_role.arn
  description = "Stops EC2 instances created by this CloudFormation stack"
  environment {
    variables = {
      StackName = local.stack_name
    }
  }
  handler = "index.stop_server_stack"
  runtime = "python3.8"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "StopStackFunction"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
  timeout = 300
}

resource "aws_lambda_function" "start_stack_function" {
  code_signing_config_arn = {
    ZipFile = ""
  }
  role = aws_iam_role.arc_gis_enterprise_iam_role.arn
  description = "Starts EC2 instances created by this CloudFormation stack"
  environment {
    variables = {
      StackName = local.stack_name
    }
  }
  handler = "index.start_server_stack"
  runtime = "python3.8"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "StartStackFunction"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
  timeout = 300
}

resource "aws_security_group" "security_group" {
  description = local.stack_name
  ingress = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port = 80
      protocol = "tcp"
      to_port = 80
    },
    {
      cidr_blocks = "0.0.0.0/0"
      from_port = 443
      protocol = "tcp"
      to_port = 443
    }
  ]
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "SecurityGroup"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    },
    {
      Key = "Name"
      Value = join("", [local.stack_name, "-SG"])
    }
  ]
  vpc_id = var.vpc_id
}

resource "aws_security_group" "security_group_ingress" {
  vpc_id = aws_security_group.security_group.arn
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  role = [
    aws_iam_role.arc_gis_enterprise_iam_role.arn
  ]
  path = "/"
}

resource "aws_launch_template" "ec2_instance_launch_template" {
  user_data = {
    BlockDeviceMappings = [
      {
        DeviceName = "/dev/sda1"
        Ebs = {
          DeleteOnTermination = True
          VolumeSize = var.instance_drive_size
          VolumeType = "gp2"
        }
      }
    ]
    IamInstanceProfile = {
      Arn = aws_iam_instance_profile.iam_instance_profile.arn
    }
    ImageId = local.AMICondition ? local.WindowsAMI ? "{{resolve:ssm:/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base:1}}" : "{{resolve:ssm:/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id:1}}" : var.ami_id
    InstanceType = var.instance_type
    KeyName = var.keypair_name
    MetadataOptions = {
      HttpEndpoint = "enabled"
      HttpTokens = "required"
    }
    NetworkInterfaces = [
      {
        AssociatePublicIpAddress = True
        DeleteOnTermination = True
        DeviceIndex = 0
        Groups = [
          aws_security_group.security_group.arn
        ]
        SubnetId = var.subnet1
      }
    ]
  }
}

resource "aws_ec2_instance_state" "file_server_ec2_instance" {
  instance_id = var.fileserver_instance_type
}

resource "aws_cloudwatch_composite_alarm" "file_server_recovery_alarm" {
  alarm_actions = [
    join("", ["arn:", data.aws_partition.current.partition, ":automate:", data.aws_region.current.name, ":ec2:recover"])
  ]
  alarm_description = "Trigger a recovery when instance status check fails for 5 consecutive minutes."
}

resource "aws_quicksight_group" "auto_scaling_group" {
}

resource "aws_inspector_resource_group" "target_group" {
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "TargetGroup"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
}

resource "aws_ssm_document" "arc_gis_server_ha_command_document" {
  content = {
    schemaVersion = "2.2"
    description = "Execute composite or nested Systems Manager documents (SSM documents) stored in a remote location."
    parameters = {
      documentUrl = {
        description = "(Required) Specify the SSM document URL that will be downloaded."
        type = "String"
      }
      documentParameters = {
        description = "(Optional) Parameters to be passed to the SSM document that will be executed."
        type = "StringMap"
        displayType = "textarea"
        default = {
        }
      }
    }
    mainSteps = [
      {
        action = "aws:runPowerShellScript"
        name = "runPowerShellScript"
        precondition = {
          StringEquals = [
            "platformType",
            "Windows"
          ]
        }
        inputs = {
          timeoutSeconds = "1800"
          runCommand = [
            "$tempfolderpath = (Join-Path 'C:\\Windows\\Temp\\esri' 'ssm')",
            "if (-not (Test-Path -Path $tempfolderpath))",
            "{",
            "   New-Item -ItemType Directory -Path $tempfolderpath",
            "}",
            "$ssmdocumentpath = (Join-Path $tempfolderpath 'ssmdocument.json')",
            "if (Test-Path -Path $ssmdocumentpath -PathType Leaf) {",
            "   Remove-Item $ssmdocumentpath",
            "}",
            "Invoke-WebRequest -Uri {{ documentUrl }} -OutFile $ssmdocumentpath"
          ]
        }
      },
      {
        action = "aws:runDocument"
        name = "runDocumentOnWindows"
        precondition = {
          StringEquals = [
            "platformType",
            "Windows"
          ]
        }
        inputs = {
          documentType = "LocalPath"
          documentPath = "C:\\Windows\\temp\\esri\\ssm\\ssmdocument.json"
          documentParameters = "{{ documentParameters }}"
        }
      },
      {
        action = "aws:runShellScript"
        name = "runShellScript"
        precondition = {
          StringEquals = [
            "platformType",
            "Linux"
          ]
        }
        inputs = {
          timeoutSeconds = "1800"
          runCommand = [

            "tempfolderpath=/tmp/esri/ssm",
          ]
        }
      },
      {
        action = "aws:runDocument"
        name = "runDocumentOnLinux"
        precondition = {
          StringEquals = [
            "platformType",
            "Linux"
          ]
        }
        inputs = {
          documentType = "LocalPath"
          documentPath = "/tmp/ssmdocument.json"
          documentParameters = "{{ documentParameters }}"
        }
      }
    ]
  }
  document_type = "Command"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "Automation"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
}

resource "aws_ssm_document" "arc_gis_server_ha_automation" {
  content = {
    schemaVersion = "0.3"
    description = "Installs and configures ArcGIS Server highly available deployment."
    assumeRole = "{{ AutomationAssumeRole }}"
    parameters = {
      AutomationAssumeRole = {
        type = "String"
        description = "(Required) The ARN of the role that allows Automation to perform the actions on your behalf."
      }
      PlatformType = {
        type = "String"
        description = "(Required) Platform type."
        allowedValues = [
          "Windows",
          "Linux"
        ]
      }
      DeploymentId = {
        type = "String"
        description = "(Required) Unique deployment id from your ArcGIS Server deployment. It must be alphanumeric string."
      }
      AWSCliBundleUrl = {
        type = "String"
        description = "(Conditional) AWS CLI Bundle URL. Required if platform type is Linux."
      }
      CincClientUrlWin = {
        type = "String"
        description = "(Required) URL of CINC client setup for Windows."
      }
      CincClientUrlLin = {
        type = "String"
        description = "(Required) URL of CINC client setup for Linux."
      }
      CookbooksUrl = {
        type = "String"
        description = "(Required) ArcGIS Chef cookbooks URL."
      }
      ArcGISVersion = {
        type = "String"
        description = "(Required) ArcGIS Server version."
      }
      ArcGISDeploymentTemplate = {
        type = "String"
        description = "(Required) ArcGIS deployment template."
      }
      DeploymentBucket = {
        type = "String"
        description = "(Required) AWS S3 bucket with authorization files and SSL certificates."
      }
      ServerLicenseFile = {
        type = "String"
        description = "(Required) AWS S3 key of ArcGIS Server license authorisation file."
      }
      SiteAdmin = {
        type = "String"
        description = "(Required) ArcGIS Server primary site administrator username."
      }
      SiteAdminPassword = {
        type = "String"
        description = "(Required) ArcGIS Server primary site administrator password."
      }
      RunAsUserUserName = {
        type = "String"
        description = "(Optional) ArcGIS Server user name."
        default = "arcgis"
      }
      RunAsUserPassword = {
        type = "String"
        description = "(Conditional) 'RunAsUserPassword' windows user account password. This is required only if operating system is Windows."
        default = ""
      }
      ConfigStoreType = {
        type = "String"
        description = "(Required) ArcGIS Server config store type."
        allowedValues = [
          "FileSystem",
          "CloudStore"
        ]
      }
      SiteDomain = {
        type = "String"
        description = "(Required) Domain name of ArcGIS Server site."
      }
      WebadaptorName = {
        type = "String"
        description = "(Optional) Name of Webadaptor for ArcGIS Server."
        default = ""
      }
      SSLCertificateFile = {
        type = "String"
        description = "(Optional) AWS S3 key of SSL certificate file in PKSC12 format."
        default = ""
      }
      SSLCertificatePassword = {
        type = "String"
        description = "(Optional) SSL certificate file password."
        default = ""
      }
      FileServerIP = {
        type = "String"
        description = "(Required) ArcGIS file server IP Address."
      }
      ExecuteRemoteSSMDocumentName = {
        type = "String"
        description = "(Required) Execute composite or nested Systems Manager documents (SSM documents) stored in a remote location."
      }
      ArcGISWinBootstrapSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to bootstrap Windows instance."
      }
      ArcGISFileServerWinDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to configure ArcGIS File server on Windows instance."
      }
      ArcGISServerWinSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to execute on EC2 instances for installing and configuring ArcGIS Server on Windows."
      }
      ArcGISLinBootstrapSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to bootstrap Linux instance."
      }
      ArcGISFileServerLinDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to configure ArcGIS File server on Linux instance."
      }
      ArcGISServerLinSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to execute on EC2 instances for installing and configuring ArcGIS Server on Linux."
      }
      ELBDNSName = {
        type = "String"
        description = "(Optional) Elastic load balancer DNS name."
        default = ""
      }
      ELBContextName = {
        type = "String"
        description = "(Optional) Elastic load balancer context name."
        default = ""
      }
      DestinationPortNumber = {
        type = "String"
        description = "(Optional) Destination port number for ArcGIS Server site."
        default = ""
      }
      TargetGroupArn = {
        type = "String"
        description = "(Optional) ARN of ArcGIS Server target group."
        default = ""
      }
      SecurityGroupId = {
        type = "String"
        description = "(Required) Security group id of ArcGIS Server deployment."
      }
      FileServerInstanceId = {
        type = "String"
        description = "(Required) AWS EC2 instance id of ArcGIS File server."
      }
      AutoScalingGroupName = {
        type = "String"
        description = "(Required) Name of AutoScaling group."
      }
      DeploymentLogs = {
        type = "String"
        description = "(Required) AWS CloudWatch log group name."
      }
      StackName = {
        type = "String"
        description = "(Required) AWS CloudFormation stack name."
      }
      WaitCondition = {
        type = "String"
        description = "(Required) Wait condition for CloudFormation stack."
      }
    }
    mainSteps = [
      {
        name = "ConditionForELB"
        action = "aws:branch"
        inputs = {
          Choices = [
            {
              NextStep = "CheckFileServerInstanceState"
              Variable = "{{ELBDNSName}}"
              EqualsIgnoreCase = ""
            }
          ]
          Default = "ConfigureArcGISServerELB"
        }
      },
      {
        name = "ConfigureArcGISServerELB"
        action = "aws:executeScript"
        onFailure = "step:SignalFailure"
        nextStep = "CheckFileServerInstanceState"
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = ""
          InputPayload = {
            SecurityGroupId = "{{SecurityGroupId}}"
            AutoscalingGroupId = "{{AutoScalingGroupName}}"
            ELBDNSName = "{{ELBDNSName}}"
            TargetGroupArn = "{{TargetGroupArn}}"
            WebadaptorName = "{{ELBContextName}}"
            DestinationPortNumber = "{{DestinationPortNumber}}"
            ServerType = "server"
            ActionName = "ConfigureArcGISServerELB"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
      },
      {
        name = "CheckFileServerInstanceState"
        action = "aws:changeInstanceState"
        maxAttempts = 3
        timeoutSeconds = 1800
        onFailure = "step:SignalFailure"
        nextStep = "RetrieveAutoScalingGroupDetails"
        inputs = {
          InstanceIds = [
            "{{FileServerInstanceId}}"
          ]
          CheckStateOnly = True
          DesiredState = "running"
        }
      },
      {
        name = "RetrieveAutoScalingGroupDetails"
        action = "aws:executeScript"
        onFailure = "step:SignalFailure"
        nextStep = "CheckInstancesState"
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = ""
          InputPayload = {
            AutoScalingGroupName = "{{AutoScalingGroupName}}"
            ActionName = "RetrieveAutoScalingGroupDetails"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
        outputs = [
          {
            Name = "PrimaryInstanceId"
            Selector = "$.Payload.PrimaryInstanceId"
            Type = "String"
          },
          {
            Name = "PrimaryInstanceIPAddress"
            Selector = "$.Payload.PrimaryInstanceIPAddress"
            Type = "String"
          },
          {
            Name = "SecondaryInstanceIds"
            Selector = "$.Payload.SecondaryInstanceIds"
            Type = "StringList"
          },
          {
            Name = "InstanceCount"
            Selector = "$.Payload.InstanceCount"
            Type = "Integer"
          },
          {
            Name = "InstanceIds"
            Selector = "$.Payload.InstanceIds"
            Type = "StringList"
          }
        ]
      },
      {
        name = "CheckInstancesState"
        action = "aws:changeInstanceState"
        maxAttempts = 3
        timeoutSeconds = 1800
        onFailure = "step:SignalFailure"
        nextStep = "ConditionForOperatingSystem"
        inputs = {
          InstanceIds = "{{RetrieveAutoScalingGroupDetails.InstanceIds}}"
          CheckStateOnly = True
          DesiredState = "running"
        }
      },
      {
        name = "ConditionForOperatingSystem"
        action = "aws:branch"
        inputs = {
          Choices = [
            {
              NextStep = "BootstrapWindowsFileServer"
              Variable = "{{PlatformType}}"
              EqualsIgnoreCase = "Windows"
            },
            {
              NextStep = "BootstrapLinuxFileServer"
              Variable = "{{PlatformType}}"
              EqualsIgnoreCase = "Linux"
            }
          ]
          Default = "SignalFailure"
        }
      },
      {
        name = "BootstrapWindowsFileServer"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ConfigureArcGISFileServerOnWindows"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          Targets = [
            {
              Key = "InstanceIds"
              Values = [
                "{{FileServerInstanceId}}"
              ]
            }
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISWinBootstrapSSMDocumentPath}}"
            documentParameters = {
              cincClientUrl = "{{CincClientUrlWin}}"
              cookbooksUrl = "{{CookbooksUrl}}"
            }
          }
        }
      },
      {
        name = "BootstrapLinuxFileServer"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ConfigureArcGISFileServerOnLinux"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          Targets = [
            {
              Key = "InstanceIds"
              Values = [
                "{{FileServerInstanceId}}"
              ]
            }
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISLinBootstrapSSMDocumentPath}}"
            documentParameters = {
              awsCliBundleUrl = "{{AWSCliBundleUrl}}"
              cincClientUrl = "{{CincClientUrlLin}}"
              cookbooksUrl = "{{CookbooksUrl}}"
            }
          }
        }
      },
      {
        name = "ConfigureArcGISFileServerOnWindows"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "BootstrapWindowsNodes"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{FileServerInstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISFileServerWinDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              arcgisDeploymentTemplate = "{{ArcGISDeploymentTemplate}}"
              runAsUserUserName = "{{RunAsUserUserName}}"
              runAsUserPassword = "{{RunAsUserPassword}}"
            }
          }
        }
      },
      {
        name = "ConfigureArcGISFileServerOnLinux"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "BootstrapLinuxNodes"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{FileServerInstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISFileServerLinDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              arcgisDeploymentTemplate = "{{ArcGISDeploymentTemplate}}"
              runAsUserUserName = "{{RunAsUserUserName}}"
            }
          }
        }
      },
      {
        name = "BootstrapWindowsNodes"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ConfigureArcGISPrimaryServerOnWindows"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          Targets = [
            {
              Key = "InstanceIds"
              Values = "{{RetrieveAutoScalingGroupDetails.InstanceIds}}"
            }
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISWinBootstrapSSMDocumentPath}}"
            documentParameters = {
              cincClientUrl = "{{CincClientUrlWin}}"
              cookbooksUrl = "{{CookbooksUrl}}"
            }
          }
        }
      },
      {
        name = "BootstrapLinuxNodes"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ConfigureArcGISPrimaryServerOnLinux"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          Targets = [
            {
              Key = "InstanceIds"
              Values = "{{RetrieveAutoScalingGroupDetails.InstanceIds}}"
            }
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISLinBootstrapSSMDocumentPath}}"
            documentParameters = {
              awsCliBundleUrl = "{{AWSCliBundleUrl}}"
              cincClientUrl = "{{CincClientUrlLin}}"
              cookbooksUrl = "{{CookbooksUrl}}"
            }
          }
        }
      },
      {
        name = "ConfigureArcGISPrimaryServerOnWindows"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ConditionForArcGISNodes"
        timeoutSeconds = 7200
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{RetrieveAutoScalingGroupDetails.PrimaryInstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISServerWinSSMDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              deploymentId = "{{DeploymentId}}"
              machineRole = "arcgis-server"
              deploymentBucket = "{{DeploymentBucket}}"
              serverLicenseFile = "{{ServerLicenseFile}}"
              siteAdmin = "{{SiteAdmin}}"
              siteAdminPassword = "{{SiteAdminPassword}}"
              runAsUserUserName = "{{RunAsUserUserName}}"
              runAsUserPassword = "{{RunAsUserPassword}}"
              configStoreType = "{{ConfigStoreType}}"
              siteDomain = "{{SiteDomain}}"
              webadaptorName = "{{WebadaptorName}}"
              sslCertificateFile = "{{SSLCertificateFile}}"
              sslCertificatePassword = "{{SSLCertificatePassword}}"
              fileServerIP = "{{FileServerIP}}"
            }
          }
        }
      },
      {
        name = "ConfigureArcGISPrimaryServerOnLinux"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ConditionForArcGISNodes"
        timeoutSeconds = 7200
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{RetrieveAutoScalingGroupDetails.PrimaryInstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISServerLinSSMDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              deploymentId = "{{DeploymentId}}"
              machineRole = "arcgis-server"
              deploymentBucket = "{{DeploymentBucket}}"
              serverLicenseFile = "{{ServerLicenseFile}}"
              siteAdmin = "{{SiteAdmin}}"
              siteAdminPassword = "{{SiteAdminPassword}}"
              configStoreType = "{{ConfigStoreType}}"
              siteDomain = "{{SiteDomain}}"
              runAsUserUserName = "{{RunAsUserUserName}}"
              webadaptorName = "{{WebadaptorName}}"
              sslCertificateFile = "{{SSLCertificateFile}}"
              sslCertificatePassword = "{{SSLCertificatePassword}}"
              fileServerIP = "{{FileServerIP}}"
            }
          }
        }
      },
      {
        name = "ConditionForArcGISNodes"
        action = "aws:branch"
        inputs = {
          Choices = [
            {
              And = [
                {
                  Variable = "{{PlatformType}}"
                  EqualsIgnoreCase = "Windows"
                },
                {
                  Variable = "{{RetrieveAutoScalingGroupDetails.InstanceCount}}"
                  NumericGreater = 1
                }
              ]
              NextStep = "ConfigureArcGISNodeServerOnWindows"
            },
            {
              And = [
                {
                  Variable = "{{PlatformType}}"
                  EqualsIgnoreCase = "Linux"
                },
                {
                  Variable = "{{RetrieveAutoScalingGroupDetails.InstanceCount}}"
                  NumericGreater = 1
                }
              ]
              NextStep = "ConfigureArcGISNodeServerOnLinux"
            }
          ]
          Default = "SignalSuccess"
        }
      },
      {
        name = "ConfigureArcGISNodeServerOnWindows"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "SignalSuccess"
        timeoutSeconds = 7200
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          Targets = [
            {
              Key = "InstanceIds"
              Values = "{{RetrieveAutoScalingGroupDetails.SecondaryInstanceIds}}"
            }
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISServerWinSSMDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              deploymentId = "{{DeploymentId}}"
              machineRole = "arcgis-server-node"
              deploymentBucket = "{{DeploymentBucket}}"
              serverLicenseFile = "{{ServerLicenseFile}}"
              siteAdmin = "{{SiteAdmin}}"
              siteAdminPassword = "{{SiteAdminPassword}}"
              runAsUserUserName = "{{RunAsUserUserName}}"
              runAsUserPassword = "{{RunAsUserPassword}}"
              configStoreType = "{{ConfigStoreType}}"
              webadaptorName = "{{WebadaptorName}}"
              sslCertificateFile = "{{SSLCertificateFile}}"
              sslCertificatePassword = "{{SSLCertificatePassword}}"
              primaryServerIP = "{{RetrieveAutoScalingGroupDetails.PrimaryInstanceIPAddress}}"
              fileServerIP = "{{FileServerIP}}"
            }
          }
        }
      },
      {
        name = "ConfigureArcGISNodeServerOnLinux"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "SignalSuccess"
        timeoutSeconds = 7200
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          Targets = [
            {
              Key = "InstanceIds"
              Values = "{{RetrieveAutoScalingGroupDetails.SecondaryInstanceIds}}"
            }
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISServerLinSSMDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              deploymentId = "{{DeploymentId}}"
              machineRole = "arcgis-server-node"
              deploymentBucket = "{{DeploymentBucket}}"
              serverLicenseFile = "{{ServerLicenseFile}}"
              siteAdmin = "{{SiteAdmin}}"
              siteAdminPassword = "{{SiteAdminPassword}}"
              runAsUserUserName = "{{RunAsUserUserName}}"
              configStoreType = "{{ConfigStoreType}}"
              webadaptorName = "{{WebadaptorName}}"
              sslCertificateFile = "{{SSLCertificateFile}}"
              sslCertificatePassword = "{{SSLCertificatePassword}}"
              primaryServerIP = "{{RetrieveAutoScalingGroupDetails.PrimaryInstanceIPAddress}}"
              fileServerIP = "{{FileServerIP}}"
            }
          }
        }
      },
      {
        name = "SignalFailure"
        action = "aws:executeScript"
        isEnd = True
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = ""
          InputPayload = {
            StackName = "{{StackName}}"
            UniqueId = "{{FileServerInstanceId}}"
            WaitCondition = "{{WaitCondition}}"
            Status = "FAILURE"
            ActionName = "SignalFailure"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
      },
      {
        name = "SignalSuccess"
        action = "aws:executeScript"
        isEnd = True
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = ""
          InputPayload = {
            StackName = "{{StackName}}"
            UniqueId = "{{FileServerInstanceId}}"
            WaitCondition = "{{WaitCondition}}"
            Status = "SUCCESS"
            ActionName = "SignalSuccess"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
      }
    ]
  }
  document_type = "Automation"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "Automation"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
}

resource "aws_cloudformation_stack" "arc_gis_server_ha_wait_condition" {}

resource "aws_ssm_association" "arc_gis_server_ha_association" {
  name = aws_ssm_document.arc_gis_server_ha_automation.created_date
  parameters = {
    AutomationAssumeRole = [
      aws_iam_role.arc_gis_enterprise_iam_role.arn
    ]
    PlatformType = [
      var.platform_type
    ]
    DeploymentId = [
      local.stack_name
    ]
    AWSCliBundleUrl = [
      "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    ]
    CincClientUrlWin = [
      "https://arcgisstore.s3.amazonaws.com/110/cincclient/cinc-16.16.13-1-x64.msi"
    ]
    CincClientUrlLin = [
      "https://omnitruck.cinc.sh/install.sh"
    ]
    CookbooksUrl = [
      "https://arcgisstore.s3.amazonaws.com/110/cookbooks/arcgis-4.0.0-cookbooks.tar.gz"
    ]
    ArcGISVersion = [
      "11.0"
    ]
    ArcGISDeploymentTemplate = [
      "arcgis-server"
    ]
    DeploymentBucket = [
      var.deployment_bucket
    ]
    ServerLicenseFile = [
      var.server_license_file_key_name
    ]
    SiteAdmin = [
      var.siteadmin_user_name
    ]
    SiteAdminPassword = [
      var.siteadmin_user_password
    ]
    RunAsUserUserName = [
      "arcgis"
    ]
    RunAsUserPassword = [
      var.arcgis_user_password
    ]
    ConfigStoreType = [
      var.config_store_type
    ]
    SiteDomain = [
      var.site_domain
    ]
    WebadaptorName = [
      var.server_webadaptor_name
    ]
    SSLCertificateFile = [
      var.ssl_certificate_file_key_name
    ]
    SSLCertificatePassword = [
      var.ssl_certificate_password
    ]
    FileServerIP = [
      aws_ec2_instance_state.file_server_ec2_instance.state
    ]
    ExecuteRemoteSSMDocumentName = [
      aws_ssm_document.arc_gis_server_ha_command_document.created_date
    ]
    ArcGISWinBootstrapSSMDocumentPath = [
      "https://arcgisstore.s3.us-east-1.amazonaws.com/110/ssmdocuments/ESRI-Bootstrap-Windows.json"
    ]
    ArcGISFileServerWinDocumentPath = [
      "https://arcgisstore.s3.us-east-1.amazonaws.com/110/ssmdocuments/ESRI-FileServer-Windows.json"
    ]
    ArcGISServerWinSSMDocumentPath = [
      "https://arcgisstore.s3.us-east-1.amazonaws.com/110/ssmdocuments/ESRI-ArcGISServer-Windows.json"
    ]
    ArcGISLinBootstrapSSMDocumentPath = [
      "https://arcgisstore.s3.us-east-1.amazonaws.com/110/ssmdocuments/ESRI-Bootstrap-Linux.json"
    ]
    ArcGISFileServerLinDocumentPath = [
      "https://arcgisstore.s3.us-east-1.amazonaws.com/110/ssmdocuments/ESRI-FileServer-Linux.json"
    ]
    ArcGISServerLinSSMDocumentPath = [
      "https://arcgisstore.s3.us-east-1.amazonaws.com/110/ssmdocuments/ESRI-ArcGISServer-Linux.json"
    ]
    ELBDNSName = [
      var.elbdns_name
    ]
    ELBContextName = [
      local.WebadaptorCondition ? "arcgis" : var.server_webadaptor_name
    ]
    DestinationPortNumber = [
      "6443"
    ]
    TargetGroupArn = [
      aws_inspector_resource_group.target_group.arn
    ]
    SecurityGroupId = [
      aws_security_group.security_group.arn
    ]
    FileServerInstanceId = [
      aws_ec2_instance_state.file_server_ec2_instance.id
    ]
    AutoScalingGroupName = [
      aws_quicksight_group.auto_scaling_group.arn
    ]
    DeploymentLogs = [
      aws_inspector_resource_group.deployment_logs.arn
    ]
    StackName = [
      local.stack_name
    ]
    WaitCondition = [
      "ArcGISServerHAWaitCondition"
    ]
  }
}

resource "aws_ssm_document" "register_arc_gis_server_node_automation" {
  content = {
    schemaVersion = "0.3"
    description = "Installs and configures ArcGIS Server highly available deployment."
    assumeRole = "{{ AutomationAssumeRole }}"
    parameters = {
      AutomationAssumeRole = {
        type = "String"
        description = "(Required) The ARN of the role that allows Automation to perform the actions on your behalf."
      }
      PlatformType = {
        type = "String"
        description = "(Required) Platform type."
        allowedValues = [
          "Windows",
          "Linux"
        ]
      }
      DeploymentId = {
        type = "String"
        description = "(Required) Unique deployment id from your ArcGIS Server deployment. It must be alphanumeric string."
      }
      AWSCliBundleUrl = {
        type = "String"
        description = "(Conditional) AWS CLI Bundle URL. Required if platform type is Linux."
      }
      CincClientUrlWin = {
        type = "String"
        description = "(Required) URL of CINC client setup for Windows."
      }
      CincClientUrlLin = {
        type = "String"
        description = "(Required) URL of CINC client setup for Linux."
      }
      CookbooksUrl = {
        type = "String"
        description = "(Required) ArcGIS Chef cookbooks URL."
      }
      ArcGISVersion = {
        type = "String"
        description = "(Required) ArcGIS Server version."
      }
      DeploymentBucket = {
        type = "String"
        description = "(Required) AWS S3 bucket with authorization files and SSL certificates."
      }
      ServerLicenseFile = {
        type = "String"
        description = "(Required) AWS S3 key of ArcGIS Server license authorisation file."
      }
      SiteAdmin = {
        type = "String"
        description = "(Required) ArcGIS Server primary site administrator username."
      }
      SiteAdminPassword = {
        type = "String"
        description = "(Required) ArcGIS Server primary site administrator password."
      }
      RunAsUserUserName = {
        type = "String"
        description = "(Optional) ArcGIS Server user name."
        default = "arcgis"
      }
      RunAsUserPassword = {
        type = "String"
        description = "(Conditional) 'RunAsUserUserName' windows user account password. This is required only if operating system is Windows."
        default = ""
      }
      ConfigStoreType = {
        type = "String"
        description = "(Required) ArcGIS Server config store type."
        allowedValues = [
          "FileSystem",
          "CloudStore"
        ]
      }
      WebadaptorName = {
        type = "String"
        description = "(Optional) Name of Webadaptor for ArcGIS Server."
        default = ""
      }
      SSLCertificateFile = {
        type = "String"
        description = "(Optional) AWS S3 key of SSL certificate file in PKSC12 format."
        default = ""
      }
      SSLCertificatePassword = {
        type = "String"
        description = "(Optional) SSL certificate file password."
        default = ""
      }
      FileServerIP = {
        type = "String"
        description = "(Required) ArcGIS FileServer IP Address."
      }
      ExecuteRemoteSSMDocumentName = {
        type = "String"
        description = "(Required) Execute composite or nested Systems Manager documents (SSM documents) stored in a remote location."
      }
      ArcGISWinBootstrapSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to bootstrap Windows instance."
      }
      ArcGISServerWinSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to execute on EC2 instances for installing and configuring ArcGIS Server on Windows."
      }
      ArcGISLinBootstrapSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to bootstrap Linux instance."
      }
      ArcGISServerLinSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to execute on EC2 instances for installing and configuring ArcGIS Server on Linux."
      }
      DeploymentLogs = {
        type = "String"
        description = "(Required) AWS CloudWatch log group name."
      }
      InstanceId = {
        type = "String"
        description = "(Required) Instance id of ArcGIS Server machine."
      }
      LifeCycleHookName = {
        type = "String"
        description = "(Required) AutoScaling life cycle hook name."
      }
      AutoScalingGroupName = {
        type = "String"
        description = "(Required) AutoScaling group name."
      }
      LifeCycleActionToken = {
        type = "String"
        description = "(Required) AutoScaling life cycle action token."
      }
    }
    mainSteps = [
      {
        name = "CheckInstanceState"
        action = "aws:changeInstanceState"
        maxAttempts = 3
        timeoutSeconds = 1800
        onFailure = "step:SignalFailure"
        nextStep = "ConditionForOperatingSystem"
        inputs = {
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CheckStateOnly = True
          DesiredState = "running"
        }
      },
      {
        name = "ConditionForOperatingSystem"
        action = "aws:branch"
        inputs = {
          Choices = [
            {
              NextStep = "BootstrapWindowsNode"
              Variable = "{{PlatformType}}"
              EqualsIgnoreCase = "Windows"
            },
            {
              NextStep = "BootstrapLinuxNode"
              Variable = "{{PlatformType}}"
              EqualsIgnoreCase = "Linux"
            }
          ]
          Default = "SignalFailure"
        }
      },
      {
        name = "BootstrapWindowsNode"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "RetrievePrimaryServerDetailsonWindows"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISWinBootstrapSSMDocumentPath}}"
            documentParameters = {
              cincClientUrl = "{{CincClientUrlWin}}"
              cookbooksUrl = "{{CookbooksUrl}}"
            }
          }
        }
      },
      {
        name = "RetrievePrimaryServerDetailsonWindows"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ParsePrimaryServerDetailsonWindows"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "AWS-RunPowerShellScript"
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            commands = []
          }
        }
      },
      {
        name = "ParsePrimaryServerDetailsonWindows"
        action = "aws:executeScript"
        onFailure = "step:SignalFailure"
        nextStep = "RetrievePrimaryServerInstallDironWindows"
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = "return (($env:InputPayload | ConvertFrom-Json).stringOfJson | ConvertFrom-Json)"
          InputPayload = {
            stringOfJson = "{{ RetrievePrimaryServerDetailsonWindows.Output }}"
          }
        }
        outputs = [
          {
            Name = "PrivateIpAddress"
            Selector = "$.Payload.PrivateIpAddress"
            Type = "String"
          },
          {
            Name = "PrimaryServerInstanceId"
            Selector = "$.Payload.PrimaryServerInstanceId"
            Type = "String"
          }
        ]
      },
      {
        name = "RetrievePrimaryServerInstallDironWindows"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ParsePrimaryServerInstallDironWindows"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "AWS-RunPowerShellScript"
          InstanceIds = [
            "{{ ParsePrimaryServerDetailsonWindows.PrimaryServerInstanceId }}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            commands = []
          }
        }
      },
      {
        name = "ParsePrimaryServerInstallDironWindows"
        action = "aws:executeScript"
        onFailure = "step:SignalFailure"
        nextStep = "ConfigureArcGISServerOnWindows"
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = "return (($env:InputPayload | ConvertFrom-Json).stringOfJson | ConvertFrom-Json)"
          InputPayload = {
            stringOfJson = "{{ RetrievePrimaryServerInstallDironWindows.Output }}"
          }
        }
        outputs = [
          {
            Name = "InstallDir"
            Selector = "$.Payload.InstallDir"
            Type = "String"
          }
        ]
      },
      {
        name = "ConfigureArcGISServerOnWindows"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "SignalSuccess"
        timeoutSeconds = 7200
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISServerWinSSMDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              deploymentId = "{{DeploymentId}}"
              machineRole = "arcgis-server-node"
              deploymentBucket = "{{DeploymentBucket}}"
              serverLicenseFile = "{{ServerLicenseFile}}"
              siteAdmin = "{{SiteAdmin}}"
              siteAdminPassword = "{{SiteAdminPassword}}"
              serverInstallDir = "{{ParsePrimaryServerInstallDironWindows.InstallDir}}"
              runAsUserUserName = "{{RunAsUserUserName}}"
              runAsUserPassword = "{{RunAsUserPassword}}"
              configStoreType = "{{ConfigStoreType}}"
              webadaptorName = "{{WebadaptorName}}"
              sslCertificateFile = "{{SSLCertificateFile}}"
              sslCertificatePassword = "{{SSLCertificatePassword}}"
              primaryServerIP = "{{ParsePrimaryServerDetailsonWindows.PrivateIpAddress}}"
              fileServerIP = "{{FileServerIP}}"
            }
          }
        }
      },
      {
        name = "BootstrapLinuxNode"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "RetrievePrimaryServerDetailsonLinux"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISLinBootstrapSSMDocumentPath}}"
            documentParameters = {
              awsCliBundleUrl = "{{AWSCliBundleUrl}}"
              cincClientUrl = "{{CincClientUrlLin}}"
              cookbooksUrl = "{{CookbooksUrl}}"
            }
          }
        }
      },
      {
        name = "RetrievePrimaryServerDetailsonLinux"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ParsePrimaryServerDetailsonLinux"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "AWS-RunShellScript"
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            commands = []
          }
        }
      },
      {
        name = "ParsePrimaryServerDetailsonLinux"
        action = "aws:executeScript"
        onFailure = "step:SignalFailure"
        nextStep = "RetrievePrimaryServerInstallDironLinux"
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = "return (($env:InputPayload | ConvertFrom-Json).stringOfJson | ConvertFrom-Json)"
          InputPayload = {
            stringOfJson = "{{ RetrievePrimaryServerDetailsonLinux.Output }}"
          }
        }
        outputs = [
          {
            Name = "PrivateIpAddress"
            Selector = "$.Payload.PrivateIpAddress"
            Type = "String"
          },
          {
            Name = "PrimaryServerInstanceId"
            Selector = "$.Payload.PrimaryServerInstanceId"
            Type = "String"
          }
        ]
      },
      {
        name = "RetrievePrimaryServerInstallDironLinux"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "ParsePrimaryServerInstallDironLinux"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "AWS-RunShellScript"
          InstanceIds = [
            "{{ ParsePrimaryServerDetailsonLinux.PrimaryServerInstanceId }}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            commands = []
          }
        }
      },
      {
        name = "ParsePrimaryServerInstallDironLinux"
        action = "aws:executeScript"
        onFailure = "step:SignalFailure"
        nextStep = "ConfigureArcGISServerOnLinux"
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = "return (($env:InputPayload | ConvertFrom-Json).stringOfJson | ConvertFrom-Json)"
          InputPayload = {
            stringOfJson = "{{ RetrievePrimaryServerInstallDironLinux.Output }}"
          }
        }
        outputs = [
          {
            Name = "InstallDir"
            Selector = "$.Payload.InstallDir"
            Type = "String"
          }
        ]
      },
      {
        name = "ConfigureArcGISServerOnLinux"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "SignalSuccess"
        timeoutSeconds = 7200
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISServerLinSSMDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              deploymentId = "{{DeploymentId}}"
              machineRole = "arcgis-server-node"
              deploymentBucket = "{{DeploymentBucket}}"
              serverLicenseFile = "{{ServerLicenseFile}}"
              siteAdmin = "{{SiteAdmin}}"
              siteAdminPassword = "{{SiteAdminPassword}}"
              runAsUserUserName = "{{RunAsUserUserName}}"
              serverInstallDir = "{{ParsePrimaryServerInstallDironLinux.InstallDir}}"
              configStoreType = "{{ConfigStoreType}}"
              webadaptorName = "{{WebadaptorName}}"
              sslCertificateFile = "{{SSLCertificateFile}}"
              sslCertificatePassword = "{{SSLCertificatePassword}}"
              primaryServerIP = "{{ParsePrimaryServerDetailsonLinux.PrivateIpAddress}}"
              fileServerIP = "{{FileServerIP}}"
            }
          }
        }
      },
      {
        name = "SignalFailure"
        action = "aws:executeScript"
        isEnd = True
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = ""
          InputPayload = {
            AutoscalingGroupId = "{{AutoScalingGroupName}}"
            LifeCycleHookName = "{{LifeCycleHookName}}"
            LifeCycleActionToken = "{{LifeCycleActionToken}}"
            LifeCycleActionResult = "CONTINUE"
            ActionName = "SignalFailure"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
      },
      {
        name = "SignalSuccess"
        action = "aws:executeScript"
        isEnd = True
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = ""
          InputPayload = {
            AutoscalingGroupId = "{{AutoScalingGroupName}}"
            LifeCycleHookName = "{{LifeCycleHookName}}"
            LifeCycleActionToken = "{{LifeCycleActionToken}}"
            LifeCycleActionResult = "CONTINUE"
            ActionName = "SignalSuccess"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
      }
    ]
  }
  document_type = "Automation"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "RegisterArcGISServerNodeAutomation"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
}

resource "aws_ssm_document" "unegister_arc_gis_server_node_automation" {
  content = {
    description = "Unregisters ArcGIS Server machine from ArcGIS Server site."
    assumeRole = "{{ AutomationAssumeRole }}"
    schemaVersion = "0.3"
    parameters = {
      AutomationAssumeRole = {
        type = "String"
        description = "(Required) The ARN of the role that allows Automation to perform the actions on your behalf."
      }
      PlatformType = {
        type = "String"
        description = "(Required) Platform type."
        allowedValues = [
          "Windows",
          "Linux"
        ]
      }
      ArcGISVersion = {
        type = "String"
        description = "(Required) ArcGIS Server version."
      }
      SiteAdmin = {
        type = "String"
        description = "(Required) ArcGIS Server primary site administrator username."
      }
      SiteAdminPassword = {
        type = "String"
        description = "(Required) ArcGIS Server primary site administrator password."
      }
      ExecuteRemoteSSMDocumentName = {
        type = "String"
        description = "(Required) Execute composite or nested Systems Manager documents (SSM documents) stored in a remote location."
      }
      ArcGISServerUnregisterWinSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to execute on EC2 instances for unregistering ArcGIS Server on Windows."
      }
      ArcGISServerUnregisterLinSSMDocumentPath = {
        type = "String"
        description = "(Required) AWS S3 path of SSM Document to execute on EC2 instances for unregistering ArcGIS Server on Linux."
      }
      DeploymentLogs = {
        type = "String"
        description = "(Required) AWS CloudWatch log group name."
      }
      InstanceId = {
        type = "String"
        description = "(Required) Instance id of ArcGIS Server machine."
      }
      LifeCycleHookName = {
        type = "String"
        description = "(Required) AutoScaling life cycle hook name."
      }
      AutoScalingGroupName = {
        type = "String"
        description = "(Required) AutoScaling group name."
      }
      LifeCycleActionToken = {
        type = "String"
        description = "(Required) AutoScaling life cycle action token."
      }
    }
    mainSteps = [
      {
        name = "RetrieveAutoScalingGroupDetails"
        action = "aws:executeScript"
        onFailure = "step:SignalFailure"
        nextStep = "ConditionForInstanceCount"
        inputs = {
          Runtime = "PowerShell Core 6.0"
          Script = ""
          InputPayload = {
            AutoScalingGroupName = "{{AutoScalingGroupName}}"
            ActionName = "RetrieveAutoScalingGroupDetails"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
        outputs = [
          {
            Name = "InstanceCount"
            Selector = "$.Payload.InstanceCount"
            Type = "Integer"
          }
        ]
      },
      {
        name = "ConditionForInstanceCount"
        action = "aws:branch"
        inputs = {
          Choices = [
            {
              NextStep = "ConditionForOperatingSystem"
              Variable = "{{RetrieveAutoScalingGroupDetails.InstanceCount}}"
              NumericGreater = 0
            }
          ]
          Default = "SignalSuccess"
        }
      },
      {
        name = "ConditionForOperatingSystem"
        action = "aws:branch"
        inputs = {
          Choices = [
            {
              NextStep = "UnregisterArcGISServerOnWindows"
              Variable = "{{PlatformType}}"
              EqualsIgnoreCase = "Windows"
            },
            {
              NextStep = "UnregisterArcGISServerOnLinux"
              Variable = "{{PlatformType}}"
              EqualsIgnoreCase = "Linux"
            }
          ]
          Default = "SignalFailure"
        }
      },
      {
        name = "UnregisterArcGISServerOnWindows"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "SignalSuccess"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISServerUnregisterWinSSMDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              siteAdmin = "{{SiteAdmin}}"
              siteAdminPassword = "{{SiteAdminPassword}}"
            }
          }
        }
      },
      {
        name = "UnregisterArcGISServerOnLinux"
        action = "aws:runCommand"
        onFailure = "step:SignalFailure"
        nextStep = "SignalSuccess"
        timeoutSeconds = 3600
        inputs = {
          DocumentName = "{{ExecuteRemoteSSMDocumentName}}"
          InstanceIds = [
            "{{InstanceId}}"
          ]
          CloudWatchOutputConfig = {
            CloudWatchOutputEnabled = "true"
            CloudWatchLogGroupName = "{{DeploymentLogs}}"
          }
          Parameters = {
            documentUrl = "{{ArcGISServerUnregisterLinSSMDocumentPath}}"
            documentParameters = {
              arcgisVersion = "{{ArcGISVersion}}"
              siteAdmin = "{{SiteAdmin}}"
              siteAdminPassword = "{{SiteAdminPassword}}"
            }
          }
        }
      },
      {
        inputs = {
          Script = ""
          Runtime = "PowerShell Core 6.0"
          InputPayload = {
            LifeCycleHookName = "{{LifeCycleHookName}}"
            LifeCycleActionToken = "{{LifeCycleActionToken}}"
            AutoscalingGroupId = "{{AutoScalingGroupName}}"
            LifeCycleActionResult = "CONTINUE"
            ActionName = "SignalFailure"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
        name = "SignalFailure"
        action = "aws:executeScript"
        isEnd = True
      },
      {
        inputs = {
          Script = ""
          Runtime = "PowerShell Core 6.0"
          InputPayload = {
            LifeCycleHookName = "{{LifeCycleHookName}}"
            LifeCycleActionToken = "{{LifeCycleActionToken}}"
            AutoscalingGroupId = "{{AutoScalingGroupName}}"
            LifeCycleActionResult = "CONTINUE"
            ActionName = "SignalSuccess"
            LogGroupName = "{{DeploymentLogs}}"
            RegionId = "{{global:REGION}}"
          }
        }
        name = "SignalSuccess"
        action = "aws:executeScript"
        isEnd = True
      }
    ]
  }
  document_type = "Automation"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "UnregisterArcGISServerNodeAutomation"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
}

resource "aws_autoscaling_lifecycle_hook" "instance_launch_life_cycle_hook" {
  autoscaling_group_name = aws_quicksight_group.auto_scaling_group.arn
  lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  default_result = "CONTINUE"
  heartbeat_timeout = 3600
  name = "InstanceLaunchHook"
}

resource "aws_autoscaling_lifecycle_hook" "instance_terminate_life_cycle_hook" {
  autoscaling_group_name = aws_quicksight_group.auto_scaling_group.arn
  lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
  default_result = "CONTINUE"
  heartbeat_timeout = 3600
  name = "InstanceTerminateHook"
}

resource "aws_iot_topic_rule_destination" "auto_scaling_instance_launch_event_rule" {
}

resource "aws_iot_topic_rule_destination" "auto_scaling_instance_terminate_event_rule" {
}

resource "aws_lambda_function" "delete_config_store_function" {
  count = locals.UseCloudStore ? 1 : 0
  code_signing_config_arn = {
    ZipFile = ""
  }
  role = aws_iam_role.arc_gis_enterprise_iam_role.arn
  description = "Delete the ArcGIS Server config store."
  handler = "index.delete_server_config_store"
  runtime = "python3.8"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "DeleteConfigStoreFunction"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
  timeout = 900
}

resource "aws_route53_resolver_query_log_config_association" "delete_config_store" {
  count = locals.UseCloudStore ? 1 : 0
}

resource "aws_lambda_function" "delete_server_elb_rules_function" {
  count = locals.ELBDNSNameCondition ? 1 : 0
  code_signing_config_arn = {
    ZipFile = ""
  }
  role = aws_iam_role.arc_gis_enterprise_iam_role.arn
  description = "Delete the Server rules from ELB."
  handler = "index.lambda_handler"
  runtime = "python3.8"
  tags = [
    {
      Key = "arcgisenterprise:cloudformation:logical-id"
      Value = "DeleteServerELBRulesFunction"
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-id"
      Value = local.stack_id
    },
    {
      Key = "arcgisenterprise:cloudformation:stack-name"
      Value = local.stack_name
    },
    {
      Key = "arcgisenterprise:cloudformation:template-name"
      Value = "arcgis-server-ha.template.json"
    },
    {
      Key = "arcgisenterprise:cloudformation:template-provider"
      Value = "Esri"
    }
  ]
  timeout = 60
}

resource "aws_s3_bucket_server_side_encryption_configuration" "delete_server_elb_rules" {
  count = locals.ELBDNSNameCondition ? 1 : 0
}

output "server_manager_dir_url" {
  description = "ArcGIS Server Manager URL"
  value = local.WebadaptorCondition ? join("", ["https://", var.site_domain, "/arcgis/manager"]) : join("", ["https://", var.site_domain, "/", var.server_webadaptor_name, "/manager"])
}

output "server_rest_dir_url" {
  description = "ArcGIS Server REST Services URL"
  value = local.WebadaptorCondition ? join("", ["https://", var.site_domain, "/arcgis/rest/services"]) : join("", ["https://", var.site_domain, "/", var.server_webadaptor_name, "/rest/services"])
}

output "server_admin_dir_url" {
  description = "ArcGIS Server Admin Directory URL"
  value = local.WebadaptorCondition ? join("", ["https://", var.site_domain, "/arcgis/admin"]) : join("", ["https://", var.site_domain, "/", var.server_webadaptor_name, "/admin"])
}

output "server_services_url" {
  description = "ArcGIS Server Services URL"
  value = local.WebadaptorCondition ? join("", ["https://", var.site_domain, "/arcgis"]) : join("", ["https://", var.site_domain, "/", var.server_webadaptor_name])
}

output "deployment_logs_url" {
  description = "Deployment Logs"
  value = join("", ["https://console.aws.amazon.com/cloudwatch/home?region=", data.aws_region.current.name, "#logStream:group=", aws_inspector_resource_group.deployment_logs.arn])
}

output "stop_stack_function_name" {
  description = "Lambda function used to stop all EC2 instances in the stack."
  value = join("", ["https://console.aws.amazon.com/lambda/home?region=", data.aws_region.current.name, "#/functions/", aws_lambda_function.stop_stack_function.arn])
}

output "start_stack_function_name" {
  description = "Lambda function used to start all EC2 instances in the stack."
  value = join("", ["https://console.aws.amazon.com/lambda/home?region=", data.aws_region.current.name, "#/functions/", aws_lambda_function.start_stack_function.arn])
}
