resource "aws_vpc" "k8svpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "k8svpc"
  }
}

resource "aws_internet_gateway" "k8svpc-igw" {
  vpc_id = aws_vpc.k8svpc.id

  tags = {
    Name = "k8svpc-igw"
  }
}

#public subnets
resource "aws_subnet" "k8s-public-subnets" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.k8svpc.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = "${var.availability_zones[count.index]}"
    map_public_ip_on_launch = true

    tags = {
      "Name" = "k8s-public-subnet-${count.index + 1}"
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
}

# private subnets
resource "aws_subnet" "k8s-private-subnets" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.k8svpc.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = "${var.availability_zones[count.index]}"

    tags = {
      "Name" = "k8s-private-subnet-${count.index + 1}"
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
}

# route table for public subnets
resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.k8svpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.k8svpc-igw.id
    }

    tags = {
        Name = "k8s-public-rt"
        status = "public"
    }
}

# route table associate with public subnets
resource "aws_route_table_association" "public-rt-assoc" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.k8s-public-subnets[count.index].id
    route_table_id = aws_route_table.public-rt.id
}

# NAT Gateway EIP
resource "aws_eip" "nat-gw-eip" {
    domain = "vpc"
    tags = {
        Name = "nat-gw-eip"
    }
}

# NAT Gateway
resource "aws_nat_gateway" "k8s-nat-gw" {
    subnet_id = aws_subnet.k8s-public-subnets[0].id
    allocation_id = aws_eip.nat-gw-eip.id
    tags = {
        Name = "k8s-nat-gw"
    }
    depends_on = [ aws_internet_gateway.k8svpc-igw ]
}

# route table for private subnets
resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.k8svpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.k8s-nat-gw.id
    }

    tags = {
        Name = "k8s-private-rt"
        status = "private"
    }
}

# route table associate with private subnets
resource "aws_route_table_association" "private-rt-assoc" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.k8s-private-subnets[count.index].id
    route_table_id = aws_route_table.private-rt.id
}

