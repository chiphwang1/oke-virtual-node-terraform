# OCI-OKE-Virual-Nodes-Terraform


## Introduction


The Terraform stack named OCI-OKE-Virtual-Nodes facilitates the deployment of an Oracle Container Engine for Kubernetes (OKE) Virtual Nodes cluster in your tenancy. This stack will automatically provision the necessary network infrastructure components such as Virtual Cloud Network (VCN), subnets, Internet Gateway, NAT Gateway, and security rules. Additionally, you can deploy the relevant policies in the root compartment of your tenancy to enable operations of OKE Virtual Nodes.

## Pre-requisites

- [OCI CLI installed with the required credentials to deploy OKE in your tenancy](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- [kubectl installed and using the context for the Kubernetes cluster where the MDS resource will be deployed](https://kubernetes.io/docs/tasks/tools/)
- [Terraform Installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


## Installation of Helm chart

**1. Clone or download the contents of this repo** 
     
     git clone https://github.com/oracle-devrel/helm-oci-mysql.git

**2. Change to the directory that holds the Helm Chart** 

      cd ./helm-oci-mysql

**3. Populate the values.yaml file with information to deploy the MDS resource**


**4. Create the namespace where the MDS resource will be deployed**

     kubectl create ns <namespace name>

**5. Install the Helm chart. Best practice is to assign the username and password during the installation of the Helm chart instead of adding it to the values.yam file.**

     helm -n <namespace name> install \
     --set database.username=<database password> \  
     --set database.password=<database password> \
       <name for this install> .
  
  **Example:**
  helm -n mysqldb --set database.username=admin  --set database.password=Admin12345 ocimds .
  
 The password must be between 8 and 32 characters long, and must contain at least 1 numeric character, 1 lowercase character, 1 uppercase character, and 1   special (nonalphanumeric) character.


**6. List the Helm installation**

     helm  -n <namespace name> ls

**7. To uninstall the Helm chart**

     helm uninstall -n <namespace name> <name of the install> .
     
  **Note:**
 uninstalling the helm chart will only remove the mysqldbsystem resource from the cluster and not from OCI. You will need to use the console or the OCI cli to remove the MDS from OCI. This is to prevent accidental deletion of the database.

## MySQL DB System value.yaml Specification


| Variables                          | Description                                                         | Type   | Mandatory |
| ---------------------------------- | ------------------------------------------------------------------- | ------ | --------- |
| `compartment_id` | Compartment to deoloy OKE Virual Nodes cluster | string | yes  |
| `region` | region to deploy the OKE Virtual Nodes Cluster  | string | yes     |
| `node_shape` | The shape of Virtual Nodes | string | yes       |
| `node_size` | The name of Virtual Nodes in the node pool  | number | yes       |
| `create_oke_virtual_node_policy` | To create the policy for for Virtual Node operations or not  | bool | yes       |
| `spec.dataStorageSizeInGBs`| Initial size of the data volume in GBs that will be created and attached. Keep in mind that this only specifies the size of the database data volume, the log volume for the database will be scaled appropriately with its shape. | int    | yes       |
| `spec.isHighlyAvailable` | Specifies if the DB System is highly available.  | boolean | yes       |
| `spec.availabilityDomain`| The availability domain on which to deploy the Read/Write endpoint. This defines the preferred primary instance. | string | yes        |
| `spec.faultDomain`| The fault domain on which to deploy the Read/Write endpoint. This defines the preferred primary instance. | string | no        |
| `spec.configuration.id` | The OCID of the Configuration to be used for this DB System. [More info about Configurations](https://docs.oracle.com/en-us/iaas/mysql-database/doc/db-systems.html#GUID-E2A83218-9700-4A49-B55D-987867D81871)| string | yes |
| `spec.description` | User-provided data about the DB System. | string | no |
| `spec.hostnameLabel` | The hostname for the primary endpoint of the DB System. Used for DNS. | string | no |
| `spec.mysqlVersion` | The specific MySQL version identifier. | string | no |
| `spec.port` | The port for primary endpoint of the DB System to listen on. | int | no |
| `spec.portX` | The TCP network port on which X Plugin listens for connections. This is the X Plugin equivalent of port. | int | no |
| `spec.ipAddress` | The IP address the DB System is configured to listen on. A private IP address of your choice to assign to the primary endpoint of the DB System. Must be an available IP address within the subnet's CIDR. If you don't specify a value, Oracle automatically assigns a private IP address from the subnet. This should be a "dotted-quad" style IPv4 address. | string | no |
| `database.username` | The admin username for the administrative user for the MuSQL DB Systesm. This should be assigned during the deployment of the Helm chart and not kept in the values.yaml file| string | yes       |
| `database.password` | The admin password for Mysql DB System. The password must be between 8 and 32 characters long, and must contain at least 1 numeric character, 1 lowercase character, 1 uppercase character, and 1 special (nonalphanumeric) character. | string | yes       |
| `autoDB.enabled` | set to true to automatically create a database in the Mysql DB System. Leave this field empty otherwise. | string | no       |
| `DBName` | if autoDB.enabled is set to true, name the database in this field. | string | no       |



## Useful commands 


**1. To check the status of the MySQL DB System run the following command**
     
     kubectl -n <namespace of mysqldbsystem> get mysqldbsystems -o wide

**2. To describe the MySQL DB System run the following command** 
     
     kubectl -n <namespace of mysqldbsystem> describe mysqldbsystems <name of mysqldbsystem>

**3. To retreive the OCID of MySQL DB System run the following command** 

      kubectl -n <namespace of mysqldbsystem> get mysqldbsystems <name of mysqldbsystem> -o jsonpath="{.items[0].status.status.ocid}"
 
**4. To retrive the admin username of the MySQL DB System run the following command**
     
     kubectl -n  <namespace of mysqldbsystem>  get secret mysqlsecret -o  jsonpath="{.data.username}" | base64 --decode

**5. To retrive the admin password of the MySQL DB System run the following command**
     
     kubectl -n  <namespace of mysqldbsystem>  get secret mysqlsecret -o  jsonpath="{.data.password}" | base64 --decode

**6. To retreive endpoint information for the MySQL DB System run the following command**
     
     kubectl -n <namespace of mysqldbsystem> get secret <name of the MySQL DB System>  -o jsonpath='{.data.Endpoints}' | base64 --decode



## Additional Resources

- [OCI Service Operator for Kuberntes (OSOK) deployed in the cluster](https://github.com/oracle/oci-service-operator)
- [MySQL SB System Service](https://www.oracle.com/mysql/)
