variable "vpc_cidr" {
  description = "vpc cidr"
  default     = "10.0.0.0/24"

}


variable "vpc_tagname" {
  description = "name of vpc"
  default     = "vpc01"

}

variable "myInternetGateway" {
  description = "internetgatewaytag"
  default     = "true"

}


variable "public_subnet_cidr1" {
  description = "cidr for the public subnet"
  default     = "10.0.0.0/25"
}

variable "public_subnet_cidr2" {
  description = "cidr for the public subnet"
  default     = "10.0.0.128/25"
}

variable "availability_zonesubnet01" {
  description = "subnet01 availability zone"
  default     = "us-east-1a"
}

variable "availability_zonesubnet02" {
  description = "subnet01 availability zone"
  default     = "us-east-1b"
}



variable "map_public_ip_on_launch1" {
  description = "to map the ip to the instance"
  default     = true
}

variable "map_public_ip_on_launch2" {
  description = "to map the ip to the instance"
  default     = true
}


variable "public_subnet_tag1" {
  description = "public_subnet_tag"
  default     = "subnet01"

}


variable "public_subnet_tag2" {
  description = "public_subnet_tag"
  default     = "subnet01"

}

variable "public_route_table_tag" {
  description = "route table tag"
  default     = "rt01"

}

variable "ami_id" {
  description = "ami_id value"



}

variable "instance_type" {
  description = "instance_id value"



}


