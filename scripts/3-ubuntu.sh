#!/bin/bash -xe

# 1a. Set HOSTNAME to "controlplane"
echo "controlplane" | sudo tee /etc/hostname
sudo hostnamectl set-hostname controlplane

# 1b. Get Host IP and create DNS alias for CP
CP_IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d '/' -f1)
sudo sed -i "1i\\$CP_IP k8scp" /etc/hosts

# 2. Prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo swapoff -a
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo tee /etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF

sudo sysctl --system

# 3. Install CRI - Docker & Containerd
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
sudo systemctl restart containerd

# 4. Install Kubeadm, Kubelet & Kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# 5. Install Cilium CLI
curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz

#### Configs and Commands ####

# 7. Add ClusterConfiguration to "$HOME" Directory
sudo tee $HOME/kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.29.2
controlPlaneEndpoint: "k8scp:6443"
networking:
  podSubnet: "10.244.0.0/16"
EOF

# 8. Kubeadm Init Command
sudo tee $HOME/kubeadm-init.txt <<EOF
kubeadm init --config=$HOME/kubeadm-config.yaml --node-name=controlplane --upload-certs | sudo tee $HOME/kubeadm-init.out
EOF

# 9. Install Cilium
sudo tee $HOME/cilium-install.txt <<EOF
cilium install
(Optional) cilium connectivity test
EOF

# 10. Install Bash Completion
sudo tee $HOME/bash-completion.txt <<EOF
# Bash Completion
sudo apt-get install -y bash-completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> $HOME/.bashrc

# Kubectl Alias & Autocomplete
alias k=kubectl
complete -o default -F __start_kubectl k
EOF

## 11. Instructions
sudo tee $HOME/instructions.txt <<EOF
1. (Optional) Confirm hostname and IP Address are listed in "/etc/hostname" and "/etc/hosts" respectively
2. Confirm Kubeadm, Kubelet, and Kubectl and installed
$ kubeadm version
$ kubectl version
$ kubelet --version
3. Confirm containerd is installed and running
$ sudo systemctl status containerd
4. Confirm or configure "kubeadm-config.yaml"
5. Run command in "kubeadm-init.txt"
6. Follow instructions after succesful init (will also be output to "kubeadm-init.out")
7. Run command in "cilium-install.txt"
8. (Optional) Run commands in "bash-completion.txt"
9. Confirm you can access the Cluster and that CoreDNS & Cilium are working
$ kubectl -n kube-system get pods
10. Create a Pod to ensure Cluster is functioning properly
EOF
