# Set cloud provider
provider "aws" {
  region     = "${var.aws_region}"
}

# Find the most recent CentOS 7 AMI
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["aws-marketplace"]
}

# Create Security Group
resource "aws_security_group" "allow-all" {
  name        = "bdausses-tfdemo-allow-all"
  description = "Allow all inbound/outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# Spin up the sample server
resource "aws_instance" "sample_server" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "${var.aws_instance_type}"
  tags = {
    Name = "TF_Demo_Server"
  }
  key_name      = "${var.key_name}"
  security_groups = ["${aws_security_group.allow-all.name}"]
  root_block_device {
    delete_on_termination = true
  }
}

# Post-provisioning steps for sample server
resource "null_resource" "sample_preparation" {
  depends_on = [aws_instance.sample_server]

    connection {
      host           ="${aws_instance.sample_server.public_ip}"
      user           = "centos"
      #agent          = true
      private_key    = "${file("${var.instance_key}")}"
    }

  # Write /tmp/cloud_logo.svg
  provisioner "file" {
    source      = "${path.module}/files/aws_cloud_logo.svg"
    destination = "/tmp/cloud_logo.svg"
  }

  # Install Docker, pull code, and start application
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y yum-utils device-mapper-persistent-data lvm2 git",
      "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo yum install -y docker-ce docker-ce-cli containerd.io",
      "sudo systemctl start docker",
      "sudo mkdir /opt/src",
      "cd /opt/src",
      "sudo git clone https://bdausses@bitbucket.org/bdausses/tf_demo_app.git",
      "cd tf_demo_app",
      "sudo cp /tmp/cloud_logo.svg /opt/src/tf_demo_app/public/images/cloud_logo.svg",
      "sudo docker build -t tf_demo_app .",
      "sudo docker run -d --rm --name tf_demo_app -p 8000:8000 tf_demo_app"
    ]
  }
}
