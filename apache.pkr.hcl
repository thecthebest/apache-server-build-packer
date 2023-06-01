variable "ami_id" {
  type = string
  default = "Please add your ami id here"
}

locals {
  app_name = "httpd"
}


source "amazon-ebs" "httpd" {
  ami_name      = "my-server-${local.app_name}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami = "${var.ami_id}"
  ssh_username = "ec2-user"
  tags = {
    Name = local.app_name
  }
}

build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.httpd"
  ]
 provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]
  }
}