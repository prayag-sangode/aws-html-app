provider "aws" {
  region = "us-east-1" 
}

resource "aws_key_pair" "jenkins_keypair" {
  key_name   = "jenkins-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "jenkins" {
  ami           = "ami-04b4f1a9cf54c11d0" 
  instance_type = "t2.micro" 
  key_name               = aws_key_pair.jenkins_keypair.key_name 
  security_groups = [aws_security_group.jenkins_sg.name]

user_data = <<EOF
#!/bin/bash -xe
apt update
apt install -y openjdk-17-jdk docker.io curl gnupg2 unzip apt-transport-https ca-certificates lsb-release

java -version

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update
apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins

usermod -aG docker jenkins
systemctl restart docker
systemctl restart jenkins

echo "jenkins ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install kubectl
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Wait for Jenkins to start before accessing password
sleep 30
cat /var/lib/jenkins/secrets/initialAdminPassword
EOF

user_data = <<EOF
#!/bin/bash -xe
apt update
apt install -y openjdk-17-jdk docker.io curl gnupg2 unzip apt-transport-https ca-certificates lsb-release

java -version

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt update
apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins

usermod -aG docker jenkins
systemctl restart docker
systemctl restart jenkins

echo "jenkins ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install kubectl
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Wait for Jenkins to start before accessing password
sleep 30
cat /var/lib/jenkins/secrets/initialAdminPassword
EOF

#  user_data = <<-EOF
#              #!/bin/bash
#              sudo apt update
#              sudo apt install -y openjdk-17-jdk
#              sudo apt install -y docker.io
#              java -version
#              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
#              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
#              sudo apt update
#              sudo apt install -y jenkins
#              sudo systemctl start jenkins
#              sudo systemctl enable jenkins
#              echo "Jenkins installed successfully."
#              echo "The initial admin password is located at /var/lib/jenkins/secrets/initialAdminPassword"
#              sudo cat /var/lib/jenkins/secrets/initialAdminPassword
#              sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release unzip
#              sudo usermod -aG docker jenkins
#              sudo systemctl restart jenkins
#              echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
#              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#              unzip awscliv2.zip
#              sudo ./aws/install
#              curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
#              sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl              
#              EOF

#  tags = {
#    Name = "Jenkins-Server"
#  }
#}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH and Jenkins traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to your IP for security
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open access for Jenkins, restrict as needed
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For HTTPS if needed
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For HTTP if needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
  description = "Public IP of the Jenkins instance"
}
