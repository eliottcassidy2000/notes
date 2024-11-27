#!/bin/bash

# Stop Kubernetes-related services
echo "Stopping Kubernetes services..."
sudo systemctl stop kubelet
sudo systemctl stop docker
sudo systemctl stop containerd

# Remove Kubernetes packages
echo "Removing Kubernetes packages..."
sudo apt-get purge -y kubelet kubeadm kubectl kubernetes-cni
sudo apt-get autoremove -y
sudo apt-get autoclean

# Remove Docker or Containerd (if not needed)
echo "Removing Docker..."
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
sudo apt-get autoremove -y
sudo apt-get autoclean

# Clean up Kubernetes configuration and data files
echo "Removing Kubernetes configuration and data..."
sudo rm -rf /etc/kubernetes
sudo rm -rf /etc/systemd/system/kubelet.service.d
sudo rm -rf /etc/systemd/system/kubelet.service
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/etcd

# Clean up network-related configuration (CNI plugins)
echo "Removing CNI configurations..."
sudo rm -rf /etc/cni
sudo rm -rf /opt/cni

# Remove logs and container data
echo "Removing logs and container data..."
sudo rm -rf /var/log/kubelet
sudo rm -rf /var/log/containers
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Remove Kubernetes-related user groups and users
echo "Removing Kubernetes-related users and groups..."
sudo deluser --remove-home kubelet
sudo delgroup kubelet

# Remove any remaining Kubernetes-related directories
echo "Removing any remaining Kubernetes-related directories..."
sudo rm -rf ~/.kube
sudo rm -rf /var/run/kubernetes
sudo rm -rf /usr/local/bin/kube*
