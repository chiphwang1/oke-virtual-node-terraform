
# Compartment to deploy OKE Virual Node Cluster
variable "compartment_id" {
    type = string
    default = ""
}



variable "region" {
    type = string
    default = "us-ashburn-1"
}

# Shape of Virtual Nodes
variable "node_shape"{
    type = string
    default = "Pod.Standard.E4.Flex"
}



# number of Virtual Nodes
variable "node_size" {
    type = number
    default = 3
}

# set to true to create the Serverless OKE policy in root compartment, required for Virtual Node Operation
# https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengvirtualnodes-Required_IAM_Policies.htm
variable "create_oke_virtual_node_policy" {
  description = "Set to true to create the resource, false to skip it."
  type        = bool
  default     = false
}

# root compartment of tenancy to create ske policy for Virtual Nodes if "create_oke_virtual_node_policy" varaiable is set to true
variable "root_compartment_id" {
    type = string
    default = ""
}