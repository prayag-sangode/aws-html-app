#!/bin/bash
# Script to install Jenkins, Docker, kubectl, Helm, and AWS CLI on Ubuntu

set -e  # Exit immediately if a command exits with a non-zero status

# Set hostname
sudo hostnamectl set-hostname jenkins.example.com

########################################
# Update system
########################################
echo "Updating system packages..."
sudo apt update -y

########################################
# Install Java (OpenJDK 17)
# jenkins-install.sh
########################################
echo "Installing OpenJDK 17..."
sudo apt install -y openjdk-17-jdk
java -version

########################################
# Install Jenkins
########################################
echo "Adding Jenkins repository..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Installing Jenkins..."
sudo apt update -y
sudo apt install -y jenkins

echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins --no-pager

echo "Jenkins installed successfully."
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword || true

########################################
# Install Docker
########################################
echo "Installing Docker..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Adding Jenkins user to docker group..."
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

########################################
# Install kubectl
########################################
echo "Installing kubectl..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
which kubectl
kubectl version --client || true

########################################
# Install Helm
########################################
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

########################################
# Install AWS CLI v2
########################################
echo "Installing AWS CLI v2..."
sudo apt-get update -y && sudo apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
aws --version

# Add jenkins user in sudoers
echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/jenkins

# Echo jenkins initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "All installations completed successfully!"
