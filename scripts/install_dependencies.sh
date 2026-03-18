#!/bin/bash
# Install Docker on EC2 (Amazon Linux 2 or Ubuntu). Required for CodeDeploy Docker deployment.
set -e

if command -v docker &>/dev/null; then
  echo "Docker already installed: $(docker --version)"
  exit 0
fi

if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo "Cannot detect OS"
  exit 1
fi

if [ "$OS" = "amzn" ] || [ "$OS" = "rhel" ]; then
  yum update -y
  yum install -y docker
  systemctl enable docker
  systemctl start docker
elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
  apt-get update -y
  apt-get install -y ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable docker
  systemctl start docker
else
  echo "Unsupported OS: $OS"
  exit 1
fi

echo "Docker installed: $(docker --version)"
