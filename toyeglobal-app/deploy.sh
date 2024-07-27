#!/usr/bin/env bash

set -euo pipefail

# set env variables
export IMAGE_TAG=$(git rev-parse --short HEAD)-$(date +%F-%H-%M)
export K8S_DEPLOYMENT_toyeglobal="${ENVIRONMENT}"
export K8S_DEPLOYMENT_toyeglobal="toyeglobal-app${ENVIRONMENT}"
export IMG_NAME="${DOCKERHUB_REPO}/${APP_NAME}:${IMAGE_TAG}"
export NAMESPACE="${ENVIRONMENT}"

echo "##### Starting build..."
docker build -t ${IMG_NAME} .
docker push ${IMG_NAME}

# Download kubectl binary
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl

chmod +x kubectl

echo "${KUBECONFIG}" > .kubeconfig

export KUBECONFIG=.kubeconfig

echo "##### Starting deploy..."

# Print the directory structure for debugging
echo "##### Printing directory structure for debugging"
ls -la toyeglobal-app/k8s/$ENVIRONMENT/

# Replacing/updating the deployment image
echo "##### Replacing/updating the deployment image"
for file in toyeglobal-app/k8s/$ENVIRONMENT/deployments/*.yaml; do
  if [ -f "$file" ]; then
    sed -i "s|##IMAGE_URL##|${IMG_NAME}|" "$file"
  else
    echo "File $file does not exist."
  fi
done

for directory in ingresses services deployments; do
  # Check if dir and yaml files exists
  if [ $(ls -1 toyeglobal-app/k8s/$ENVIRONMENT/$directory/*.yaml 2>/dev/null | wc -l) != 0 ]; then
    ./kubectl apply -f toyeglobal-app/k8s/$ENVIRONMENT/$directory -n $ENVIRONMENT
  else
    echo "No YAML files found in toyeglobal-app/k8s/$ENVIRONMENT/$directory"
  fi
done

./kubectl -n ${ENVIRONMENT} rollout status deployment ${K8S_DEPLOYMENT_toyeglobal} -w --timeout=5m

echo "##### ... done deploying k8s/$ENVIRONMENT/ to ${NAMESPACE}"