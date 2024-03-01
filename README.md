# Deploy Kubeadm-Kubernetes Cluster on EC2 using Terraform

Exercise in using a User Data script to automatically configure the prerequisites for a Kubeadm-based Kubernetes Cluster.

- Terraform
- AWS EC2
- Kubernetes
- Containerd
- Cilium

## Basic AWS Infrastructure
- VPC
- Single Public Subnet
- Internet Gateway
- ASG

## Create Kubeadm Kubernetes Cluster
- Install CRI [containerd.io](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)
- Install [Kubeadm, Kubelet & Kubectl](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- Install CNI [Cilium](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/)

#### User Data script at `scripts/3-ubuntu.sh`

## Instructions
#### Found in `instructions.txt` after User Data script has completed

1. (Optional) **Hostname & Hosts**  
a. Confirm hostname is listed in `/etc/hostname`  
b. Confirm IPv4 address is listed in `/etc/hosts`  
**Note:** You can also pass `--node-name` argument in `kubeadm init` command 

3. **Confirm Kubeadm, Kubelet, and Kubectl and installed**  
- `$ kubeadm version`
- `$ kubectl version`
- `$ kubelet --version`

3. **Confirm containerd is installed and running**  
    `$ sudo systemctl status containerd`

4. **Confirm or configure `kubeadm-config.yaml`**

5. **Run command in `kubeadm-init.txt`**

6. **Follow instructions after succesful init | will also be output to `kubeadm-init.out`**

7. **Run command in `cilium-install.txt`**

8. (Optional) **Bash Completion & Kubectl Alias and Autocomplete**  
a. Run *Bash* commands in `bash-completion.txt`  
b. Run *Kubectl* commands in `bash-completion.txt`

9. **Confirm you can access the Cluster and that CoreDNS & Cilium are working**  
    `$ kubectl -n kube-system get pods`

10. **Create a Pod to ensure Cluster is functioning properly**  
    `$ kubectl run nginx --image=nginx:1.18`


**Note:** If only using a single Controlplane Node, you may have to:
   1. Add *Tolerations* to Pods/Deployments/etc.
   2. Remove *Taint* on Controlplane