


provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# Generate SSH Key Pair
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "deployer_key1" {
  key_name   = "deployer_key1"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Save the private key locally for SSH access
resource "local_file" "ssh_key" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "${path.module}/deployer_key1.pem"
  file_permission = "0600"
}

# Create a VPC for the instance
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}



# Create an Internet Gateway to allow internet access
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# Add a route to the internet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}



# Define a Security Group for SSH Access
resource "aws_security_group" "app_sg" {
  name        = "app_security_group"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows SSH from any IP. Restrict to your IP if desired.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get the latest Amazon Linux 2 AMI ID
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create an EC2 Instance with SSH access
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
 
  
  key_name               = aws_key_pair.deployer_key1.key_name

  tags = {
    Name = "AppServer"
  }
}

output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
  description = "The public IP of the EC2 instance."
}

output "ssh_key_location" {
  value = local_file.ssh_key.filename
  description = "The location of the SSH private key to connect to the instance."
}
