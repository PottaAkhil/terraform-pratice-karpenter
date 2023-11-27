data "kubectl_path_documents" "docs" {
     pattern = "./manifest/*.yaml"
 }
 
 resource "kubectl_manifest" "test" {
     for_each  = toset(data.kubectl_path_documents.docs.documents)
     yaml_body = each.value
     depends_on = [
       null_resource.kubectl,
     ]
 }

 resource "null_resource" "kubectl" {
   provisioner "local-exec" {
     command  = "aws eks --region ${var.region} update-kubeconfig --name ${var.eks_cluster_name}"
           }
        depends_on = [ aws_eks_cluster.cluster ]
    }

 resource "null_resource" "apply" {
   provisioner "local-exec" {
     command = "kubectl apply -f C:/Users/Akhil/Downloads/terraform-pratice/manifest/ingress-nginx-controller.yaml"
                 
   }
        depends_on = [ aws_eks_cluster.cluster ]
    }

 resource "null_resource" "apply-1" {
   provisioner "local-exec" {
     command = "kubectl apply -f C:/Users/Akhil/Downloads/terraform-pratice/manifest/metric-server.yaml"

   }
        depends_on = [ aws_eks_cluster.cluster ]
    }
 resource "null_resource" "appl-2" {
   provisioner "local-exec" {
     command = "kubectl apply -f C:/Users/Akhil/Downloads/terraform-pratice/manifest/provisioner.yaml"
                 
                 
   }
        depends_on = [ aws_eks_cluster.cluster ]
    }