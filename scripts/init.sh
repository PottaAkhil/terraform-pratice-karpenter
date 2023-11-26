#!/bin/bash
sudo su - ubuntu
sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.26.2/2023-03-17/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv kubectl /usr/local/bin
sudo apt install unzip
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
aws eks update-kubeconfig --name test-cluster --region us-east-1
kubectl apply -f ./manifest/cluster-autoscaler.yml
kubectl get pods -A
