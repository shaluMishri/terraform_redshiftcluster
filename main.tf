# main.tf 
# Input values for provider and create a VPC
provider "aws" {
  region  = var.region
  profile = var.profile
} # end provider



# create the VPC
resource "aws_vpc" "My_VPC" {
  cidr_block       = var.vpcCIDRblock
  instance_tenancy = var.instanceTenancy
  tags = {
    Name = "My VPC"
  }
} # end resource


# create the Public Subnet
resource "aws_subnet" "My_VPC_Subnet_Public" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "My VPC Public Subnet"
  }
} # end resource

# create the Private Subnet
resource "aws_subnet" "My_VPC_Subnet_Private" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.subnetCIDRblock1
  availability_zone       = var.availabilityZone
  map_public_ip_on_launch = "false"
  tags = {
    Name = "My VPC Private Subnet"
  }
} # end resource

#create the security group
resource "aws_default_security_group" "redshift_security_group" {
  vpc_id = "aws_vpc.My_VPC.id"
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "redshift-sg"
  }
}

# Create the Security Group
resource "aws_security_group" "My_VPC_Security_Group_Private" {
  vpc_id      = "aws_vpc.My_VPC.id"
  name        = "My VPC Security Group Private"
  description = "My VPC Security Group Private"
  ingress {
    security_groups = ["${aws_security_group.My_VPC_Security_Group_Public.id}"]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "My VPC Security Group Private"
  }
}


resource "aws_security_group" "My_VPC_Security_Group_Public" {
  vpc_id      = aws_vpc.My_VPC.id
  name        = "My VPC Security Group Public"
  description = "My VPC Security Group Public"
  ingress {
    cidr_blocks = ["${var.ingressCIDRblockPub}"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["${var.ingressCIDRblockPub}"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "My VPC Security Group Public"
  }
}


# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_GW" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "My VPC Internet Gateway"
  }
} # end resource


# Create the Route Table
resource "aws_route_table" "My_VPC_route_table" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "My VPC Route Table"
  }
} # end resource


# Create the Internet Access
resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.My_VPC_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
} # end resource

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet_Public.id
  route_table_id = aws_route_table.My_VPC_route_table.id
} # end resource

#create S3 bucket
resource "aws_s3_bucket" "jimdo-test" {
  bucket = var.bucket_name
  acl    = "private"
}

# IAM Role for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  runtime = "python3.8"
}
# Create the VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.My_VPC.id
  service_name = "com.amazonaws.us-east-1.s3"
} # end resource



# Associate route table with VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "route_table_association" {
  route_table_id  = aws_route_table.My_VPC_route_table.id
  vpc_endpoint_id = "{aws_vpc_endpoint.s3.id}"
} # end resource

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "dbname"
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "tblname"
  database_name = "dbname"
}


resource "aws_redshift_cluster" "my-redshift-cluster" {
  cluster_identifier = var.cluster_identifier
  database_name      = var.database_name
  master_username    = var.admin_user
  master_password    = var.admin_password
  node_type          = var.node_type
  cluster_type       = var.cluster_type
  cluster_subnet_group_name   = join("", aws_redshift_subnet_group.default.*.id)
  publicly_accessible         = var.publicly_accessible
  port                        = var.port
  cluster_version             = var.engine_version
  number_of_nodes             = var.nodes
  encrypted                   = var.encrypted
  enhanced_vpc_routing        = var.enhanced_vpc_routing
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.final_snapshot_identifier
  snapshot_identifier         = var.snapshot_identifier
  snapshot_cluster_identifier = var.snapshot_cluster_identifier
  iam_roles                   = var.iam_roles
  depends_on = [
    aws_redshift_subnet_group.default,
    aws_redshift_parameter_group.default
  ]
  logging {
    enable        = var.logging
    bucket_name   = var.logging_bucket_name
    s3_key_prefix = var.logging_s3_key_prefix
  }
  
}

resource "aws_redshift_subnet_group" "default" {
  name        = "mysubnetgroup"
  subnet_ids  = var.subnet_ids
  description = "Allowed subnets for Redshift Subnet group"
}

resource "aws_redshift_parameter_group" "default" {
  name   = "myparametergroup"
  family = "redshift-1.0"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}