# Deploy EC2 Instance running a Kubeadm Bootstrapped Kubernetes Cluster

## Basic AWS Infrastructure
- VPC
- Single Public Subnet
- Internet Gateway
- ASG

## Create Kubeadm Kubernetes Cluster
- Install CRI [ containerd.io ]
- Install Kubeadm, Kubelet & Kubectl
- Install CNI [ Cilium ]

#### User Data script at "scripts/3-ubuntu.sh"
