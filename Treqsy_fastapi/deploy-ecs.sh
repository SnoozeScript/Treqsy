#!/bin/bash

# Exit on error
set -e

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check required variables
for var in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_ACCOUNT_ID AWS_REGION ECS_CLUSTER ECS_SERVICE; do
  if [ -z "${!var}" ]; then
    echo "Error: $var is not set"
    exit 1
  fi
done

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push the Docker image
IMAGE_NAME="livestream-api"
ECR_REPOSITORY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME"
TAG="$(git rev-parse --short HEAD)"

# Build the Docker image
docker build -t $IMAGE_NAME:$TAG -f Dockerfile.prod .

# Tag the image
docker tag $IMAGE_NAME:$TAG $ECR_REPOSITORY:$TAG
docker tag $IMAGE_NAME:$TAG $ECR_REPOSITORY:latest

# Push the image
docker push $ECR_REPOSITORY:$TAG
docker push $ECR_REPOSITORY:latest

# Update ECS service
echo "Updating ECS service..."
aws ecs update-service \
  --cluster $ECS_CLUSTER \
  --service $ECS_SERVICE \
  --force-new-deployment \
  --region $AWS_REGION

echo "Deployment initiated. Please check the ECS console for status."
