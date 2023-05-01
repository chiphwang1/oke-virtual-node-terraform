provider "kubernetes" {
    config_path = "/tmp/kubeconfig"
}

resource "local_file" "kubeconfig" {
  count = var.create_metrics_server ? 1 : 0  
   depends_on = [
  oci_containerengine_virtual_node_pool.create_node_pool_details0
  ] 
  content  = data.oci_containerengine_cluster_kube_config.virtual_cluster_kube_config.content
  filename = "/tmp/kubeconfig"
}


# wait for /tmp/kubeconfig to be wirtten"
resource "time_sleep" "wait_1min_demo" {
  count = var.create_metrics_server ? 1 : 0 
  depends_on = [
  local_file.kubeconfig
  ]
  create_duration = "30s"
}


resource "null_resource" "create_metrics_server" {
  count = var.create_metrics_server ? 1 : 0 
  depends_on = [time_sleep.wait_1min_demo]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig /tmp/kubeconfig create -f ./generated/components.yaml" 

}

}





