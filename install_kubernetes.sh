#!/bin/bash

# Update system and install dependencies
echo "Updating the system and installing dependencies..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    lsb-release \
    iptables \
    socat \
    conntrack

# Add Docker's official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker's stable repository
echo "Adding Docker repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker (used by containerd)
echo "Installing containerd..."
sudo apt-get update -y
sudo apt-get install -y containerd.io

# Configure containerd to use systemd as cgroup driver
echo "Configuring containerd to use systemd cgroup driver..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/systemd-cgroup = false/systemd-cgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Add Kubernetes APT repository and GPG key
echo "Adding Kubernetes GPG key..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "Adding Kubernetes repository..."
echo "deb [signed-by=/usr/share/keyrings/k8s-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-1.30 main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
echo "Installing Kubernetes components (kubeadm, kubelet, kubectl)..."
sudo apt-get update -y
sudo apt-get install -y kubeadm=1.30.7-00 kubelet=1.30.7-00 kubectl=1.30.7-00

# Hold Kubernetes packages at the current version to avoid updates
echo "Holding Kubernetes package versions..."
sudo apt-mark hold kubeadm kubelet kubectl

# Enable and start kubelet service
echo "Enabling and starting kubelet service..."
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Set up kubelet to use containerd as the container runtime
echo "Configuring kubelet to use containerd runtime..."
sudo mkdir -p /etc/systemd/system/kubelet.service.d
echo "[Service]" | sudo tee /etc/systemd/system/kubelet.service.d/10-containerd.conf > /dev/null
echo "Environment=\"KUBELET_EXTRA_ARGS=--container-runtime=remote --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --cgroup-driver=systemd\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-containerd.conf > /dev/null

# Reload systemd configuration and restart kubelet
echo "Reloading systemd and restarting kubelet..."
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Confirm Kubernetes components are installed and running
echo "Verifying Kubernetes installation..."
kubeadm version
kubelet version
kubectl version --client

# Initialize Kubernetes master node (Optional)
# If you're setting up a Kubernetes master node, uncomment and configure the following line:
# sudo kubeadm init --kubernetes-version v1.30.7 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.97.0.0/16

echo "Kubernetes installation complete! You can now initialize the cluster (if applicable)."
