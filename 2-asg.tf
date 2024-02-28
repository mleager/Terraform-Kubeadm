data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*jammy-22.04*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.1.0"

  name        = "asg-sg"
  description = "Allow incoming and outgoing HTTP and HTTPS from all sources."
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-all"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
  # ingress_with_cidr_blocks = [ 
  #   {
  #     from_port   = -1
  #     to_port     = -1
  #     protocol    = -1
  #     cidr_block  = "0.0.0.0/0"
  #     description = "Allow all incoming traffic on all ports to EC2 Instance"
  #   } 
  # ]

  # egress_with_cidr_blocks = [ 
  #   {
  #     from_port = -1
  #     to_port = -1
  #     protocol = -1
  #     cidr_block = "0.0.0.0/0"
  #     description = "Allow all outgoing traffic on all ports from EC2 Instance"
  #   }
  # ]
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~>7.3.1"

  # Autoscaling group
  name = "${var.project}-asg"

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_grace_period = "30"
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.public_subnets
  force_delete              = true

  # Launch template
  launch_template_name        = "${var.project}-template"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = data.aws_ami.ubuntu_ami.id
  instance_type     = var.instance_type
  user_data         = filebase64(var.user_data)
  security_groups   = [module.asg_sg.security_group_id]
  ebs_optimized     = false
  enable_monitoring = false

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_instance_profile_name   = "k8s-instance-profile"
  iam_role_name               = "${var.project}-role"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role example"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # This will ensure imdsv2 is enabled, required, and a single hop which is aws security
  # best practices
  # See https://docs.aws.amazon.com/securityhub/latest/userguide/autoscaling-controls.html#autoscaling-4
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Environment = "dev"
    Project     = "${var.project}"
  }
}
