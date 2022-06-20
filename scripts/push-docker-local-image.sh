#!/bin/bash
set -x

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker tag $IMAGE_LOCAL $ECR_REPOSITORY_URI:latest

docker push $ECR_REPOSITORY_URI:latest