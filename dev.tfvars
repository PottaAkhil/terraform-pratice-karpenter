cidr = "192.168.0.0/16"
public_Subnet = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24","192.168.7.0/24", "192.168.8.0/24", "192.168.9.0/24"]
private_Subnet = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
routtable_cidr = "0.0.0.0/0"
key_name = "terraformnew"
number = "1"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c","us-east-1a", "us-east-1a", "us-east-1b"]
rules =  [
    {
      port        = 80
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 3689
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

eks_cluster_name = "test-cluster"
resource_tags =  { 
    "env"        = "dev"
    "project"    = "Akhil"
    "Iaac"       = "Terraform"
  }

region = "us-east-1"

# 

