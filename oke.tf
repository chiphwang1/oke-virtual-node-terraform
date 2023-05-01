provider "oci" {
	region = var.region
}


# get service ocid for region
data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


# get the availability domains for the region
data "oci_identity_availability_domains" "ad" {
  compartment_id =  var.compartment_id
}


# get the fault domains of the availability domain
data "oci_identity_fault_domains" "fd" {
  compartment_id    = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
}


# put availability domains in a list
locals {
  # Get the list of availability domain names for the region
  ad_names = [for ad in data.oci_identity_availability_domains.ad.availability_domains : ad.name]
}

resource "oci_containerengine_cluster" "generated_oci_containerengine_cluster" {
	cluster_pod_network_options {
		cni_type = "OCI_VCN_IP_NATIVE"
	}
	compartment_id = var.compartment_id
	endpoint_config {
		is_public_ip_enabled = "true"
		subnet_id = "${oci_core_subnet.kubernetes_api_endpoint_subnet.id}"
	}
	freeform_tags = {
		"OKEclusterName" = "demo-cluster"
	}
	kubernetes_version = var.kubernetes_version
	name = "demo-cluster"
	options {
		admission_controller_options {
			is_pod_security_policy_enabled = "false"
		}
		persistent_volume_config {
			freeform_tags = {
				"OKEclusterName" = "demo-cluster"
			}
		}
		service_lb_config {
			freeform_tags = {
				"OKEclusterName" = "demo-cluster"
			}
		}
		service_lb_subnet_ids = ["${oci_core_subnet.service_lb_subnet.id}"]
	}
	vcn_id = "${oci_core_vcn.generated_oci_core_vcn.id}"
	
	 # cluster type "ENHANCED_CLUSTER" or "BASIC_CLUSTER"
	type = "ENHANCED_CLUSTER"
}


resource "oci_containerengine_virtual_node_pool" "create_node_pool_details0" {
	cluster_id = "${oci_containerengine_cluster.generated_oci_containerengine_cluster.id}"
	compartment_id = var.compartment_id
	freeform_tags = {
		"OKEnodePoolName" = "pool1"
	}

	
	placement_configurations {

        #Required
        availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
        subnet_id = "${oci_core_subnet.node_subnet.id}"
		fault_domain = [data.oci_identity_fault_domains.fd.fault_domains[0].name]
		
        
    }


	 pod_configuration {
        #Required
        shape = var.node_shape
        subnet_id = "${oci_core_subnet.node_subnet.id}"
    }	

	# number of Virtual Nodes
	size = var.node_size
	display_name = "Virtual_demo"
	
	
	
}
