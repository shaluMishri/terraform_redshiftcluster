# variables.tf
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "region in which to create cluster"
}

variable "profile" {
  type        = string
  default     = "default"
  description = "profile"
}

variable "public_instance" {
  type = string
}

variable "private_instance" {
  type = string
}

variable "availabilityZone" {
  default = "us-east-1b"
}
variable "instanceTenancy" {
  type        = string
  default     = "default"
}
variable "dnsSupport" {
  default = true
}
variable "dnsHostNames" {
  default = true
}
variable "vpcCIDRblock" {
  default = "10.0.0.0/16"
}
variable "subnetCIDRblock" { # for private subnet
  default = "10.0.0.0/24"
}
variable "subnetCIDRblock1" { # for public subnet
  default = "10.0.1.0/24"
}
variable "destinationCIDRblock" {
  default = "0.0.0.0/0"
}
variable "ingressCIDRblockPriv" {
  type    = string
  default = "10.0.1.0/24"
}
variable "ingressCIDRblockPub" {
  type    = string
  default = "0.0.0.0/0"
}
variable "mapPublicIP" {
  default = true
}

variable "bucket_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "cluster_identifier" {
  type        = string
  default     = ""
  description = "The Redshift Cluster Identifier. Must be a lower case string. Will use generated label ID if not supplied"
}

variable "database_name" {
  type        = string
  default     = "dev"
  description = "The name of the first database to be created when the cluster is created"
}

variable "admin_user" {
  type        = string
  default     = "admin"
  description = "(Required unless a snapshot_identifier is provided) Username for the master DB user"
}

variable "admin_password" {
  type        = string
  default     = ""
  description = "(Required unless a snapshot_identifier is provided) Password for the master DB user"
}

variable "node_type" {
  type        = string
  default     = "dc2.large"
  description = "The node type to be provisioned for the cluster. See https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-clusters.html#working-with-clusters-overview"
}

variable "cluster_type" {
  type        = string
  default     = "single-node"
  description = "The cluster type to use. Either `single-node` or `multi-node`"
}
variable "cluster_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "List of Redshift parameters to apply"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC subnet IDs"
}

variable "vpc_security_groups" {
  type        = list(string)
  default     = []
  description = "A list of Virtual Private Cloud (VPC) security groups to be associated with the cluster. Used for EC2-VPC platform"
}

variable "engine_version" {
  type        = string
  default     = "1.0"
  description = "The version of the Amazon Redshift engine to use"
}

variable "nodes" {
  type        = number
  default     = 1
  description = "The number of compute nodes in the cluster. This parameter is required when the ClusterType parameter is specified as multi-node"
}
variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "If true, the cluster can be accessed from a public network"
}
variable "port" {
  type        = number
  default     = 5439
  description = "The port number on which the cluster accepts incoming connections"
}
variable "encrypted" {
  type        = bool
  description = "Specifies whether the cluster is encrypted at rest"
  default     = false
}

variable "enhanced_vpc_routing" {
  type        = bool
  description = "If true , enhanced VPC routing is enabled"
  default     = false
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Determines whether a final snapshot of the cluster is created before Amazon Redshift deletes the cluster"
}

variable "final_snapshot_identifier" {
  type        = string
  default     = null
  description = "The identifier of the final snapshot that is to be created immediately before deleting the cluster. If this parameter is provided, `skip_final_snapshot` must be `false`"
}

variable "snapshot_identifier" {
  type        = string
  default     = null
  description = "The name of the snapshot from which to create the new cluster"
}

variable "snapshot_cluster_identifier" {
  type        = string
  default     = null
  description = "The name of the cluster the source snapshot was created from"
}

variable "owner_account" {
  type        = string
  default     = null
  description = "The AWS customer account used to create or copy the snapshot. Required if you are restoring a snapshot you do not own, optional if you own the snapshot"
}

variable "iam_roles" {
  type        = list(string)
  description = "A list of IAM Role ARNs to associate with the cluster. A Maximum of 10 can be associated to the cluster at any time"
  default     = []
}

variable "logging" {
  type        = bool
  default     = false
  description = "If true, enables logging information such as queries and connection attempts, for the specified Amazon Redshift cluster"
}

variable "logging_bucket_name" {
  type        = string
  default     = null
  description = "The name of an existing S3 bucket where the log files are to be stored. Must be in the same region as the cluster and the cluster must have read bucket and put object permissions"
}

variable "logging_s3_key_prefix" {
  type        = string
  default     = null
  description = "The prefix applied to the log file names"
}

variable "default_security_group" {
  type        = bool
  default     = true
  description = "Specifies whether or not to create default security group for The Amazon Redshift cluster"
}