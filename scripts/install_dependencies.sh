#!/bin/bash
yum update -y || apt update -y
yum install -y nginx || apt install -y nginx
systemctl enable nginx
