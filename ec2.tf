data "aws_ami_ids" "ubuntu" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami_ids.ubuntu.ids[0]
  instance_type = "t2.micro"
  count =var.number
  key_name      = aws_key_pair.kyc_app_public_key.key_name
  subnet_id     = aws_subnet.public[count.index].id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data     = file("${path.module}/scripts/init.sh")
  iam_instance_profile = aws_iam_instance_profile.profile.name
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = 40
  }
  tags = {
    Name = count.index == 0 ? "terraform" : "new-terraform"
  }
}

resource "aws_iam_instance_profile" "profile" {
  name = "new-test"
  role = aws_iam_role.session-role.name
}

resource "aws_iam_policy" "eks_policy" {
  name        = "EksEc2Policy"
  description = "IAM policy for EKS access"

  policy = <<-JSON
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "eks:*"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "eks:*",
          "Resource": "arn:aws:eks:us-east-1:926601094987:cluster/test-cluster"
        }
      ]
    }
  JSON
}

resource "aws_iam_policy" "cluster-access" {
  name        = "cluster-access-policy"
  description = "IAM policy for cluster access"

  policy = <<-JSON
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": "ec2:*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "eks:*"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "eks.amazonaws.com"
            }
          }
        }
      ]
    }
  JSON
}



resource "aws_iam_role" "session-role" {
  name               = "test_role"
  assume_role_policy = <<-JSON
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  JSON
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.session-role.name
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = aws_iam_policy.eks_policy.arn
  role       = aws_iam_role.session-role.name
}

resource "aws_iam_role_policy_attachment" "cluster-access" {
  policy_arn = aws_iam_policy.cluster-access.arn
  role       = aws_iam_role.session-role.name
}