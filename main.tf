############################  Defining VPC ############################
resource "aws_vpc" "webservervpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_tagname
  }
}

############################ myInternetGateway  ###########################
resource "aws_internet_gateway" "mywebserverIGW" {
  vpc_id = aws_vpc.webservervpc.id

  tags = {
    name = var.myInternetGateway
  }
}

########################## Defining Public subnet ######################
resource "aws_subnet" "subnet01" {
  vpc_id                  = aws_vpc.webservervpc.id
  cidr_block              = var.public_subnet_cidr1
  availability_zone       = var.availability_zonesubnet01
  map_public_ip_on_launch = var.map_public_ip_on_launch1

  tags = {
    Name = var.public_subnet_tag1

  }
}

resource "aws_subnet" "subnet02" {
  vpc_id                  = aws_vpc.webservervpc.id
  cidr_block              = var.public_subnet_cidr2
  availability_zone       = var.availability_zonesubnet02
  map_public_ip_on_launch = var.map_public_ip_on_launch2

  tags = {
    Name = var.public_subnet_tag2

  }
}


######################## creating route table ###############################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.webservervpc.id
  tags = {
    Name = var.public_route_table_tag
  }
}



######################## creating routing table ##############################
resource "aws_route" "creating_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mywebserverIGW.id

}


############################ Subnet association to route table ########################
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.subnet01.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.subnet02.id
  route_table_id = aws_route_table.public_route_table.id
}


##################### Creation of security group #######################
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.webservervpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

############################# attaching eni #####################################
resource "aws_network_interface" "myeni" {
  subnet_id = aws_subnet.subnet01.id

  tags = {
    Name = "primary_network_interface"
  }
}

################################  key pair #################################
resource "aws_key_pair" "webserverkeypair" {
  key_name   = "terraform-webserver.pem"
  public_key = file("~/.ssh/id_rsa.pub")
}

#################################### creating aws webserver ec2instance #####################
resource "aws_instance" "webserverinstance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.webserverkeypair.id
  subnet_id              = aws_subnet.subnet01.id
  availability_zone      = var.availability_zonesubnet01
  vpc_security_group_ids = [aws_security_group.webSg.id]


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "index.html"     # Replace with the path to your local file
    destination = "/var/www/html/" # Replace with the path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo service httpd restart"
    ]
  }
  tags = {
    name = "webserverinstance"
  }
}

resource "aws_instance" "webserverinstance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.webserverkeypair.id
  subnet_id              = aws_subnet.subnet01.id
  availability_zone      = var.availability_zonesubnet01
  vpc_security_group_ids = [aws_security_group.webSg.id]


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "index.html"     # Replace with the path to your local file
    destination = "/var/www/html/" # Replace with the path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo service httpd restart"
    ]
  }
}


###########################  creating loadbalancers #################################
resource "aws_lb" "webserver_alb" {
  name               = "webserver-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webSg.id]
  subnet_mapping {
    subnet_id = aws_subnet.subnet01.id
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.webservervpc.id

}

resource "aws_lb_listener" "alb_forward_listener" {
  load_balancer_arn = aws_lb.webserver_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}