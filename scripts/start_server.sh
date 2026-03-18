#!/bin/bash
# Pull image from ECR and run app container. Used by CodeDeploy ApplicationStart.
# EC2 instance must have IAM role with ecr:GetAuthorizationToken and ecr:BatchGetImage.
set -e

APP_DIR="/opt/dragon-live"
CONTAINER_NAME="dragon-live"
IMAGE_FILE="${APP_DIR}/image.txt"
HOST_PORT="${HOST_PORT:-3000}"

if [ ! -f "$IMAGE_FILE" ]; then
  echo "Error: $IMAGE_FILE not found."
  exit 1
fi

IMAGE_URI=$(cat "$IMAGE_FILE")
echo "Image: $IMAGE_URI"

# ECR registry is the first part of the image URI (before first /)
REGISTRY="${IMAGE_URI%%/*}"
# Extract region from registry (e.g. 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com -> ap-northeast-1)
AWS_REGION="${AWS_REGION:-$(echo "$REGISTRY" | sed -n 's/.*\.dkr\.ecr\.\([^.]*\)\.amazonaws\.com/\1/p')}"
if [ -z "$AWS_REGION" ]; then
  AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null || true)
fi
if [ -z "$AWS_REGION" ]; then
  echo "Error: Could not determine AWS_REGION."
  exit 1
fi

echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"

echo "Pulling image..."
docker pull "$IMAGE_URI"

# Remove any leftover container (e.g. if ApplicationStop failed), then run
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "Starting container: $CONTAINER_NAME"
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "${HOST_PORT}:3000" \
  -e NODE_ENV=production \
  "$IMAGE_URI"

echo "App is running on port $HOST_PORT."
