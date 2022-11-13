#!/bin/bash

echo -e "\n🚢 Setting up Kubernetes cluster...\n"

kapp deploy -a test-setup -f test/test-setup -y
kubectl config set-context --current --namespace=carvel-test

# Wait for the generation of a token for the new Service Account
while [ $(kubectl get configmap --no-headers | wc -l) -eq 0 ] ; do
  sleep 3
done

echo -e "📦 Deploying Carvel package...\n"

cd package
kctrl dev -f package-resources.yml --local  -y
cd ..

echo -e "🎮 Verifying package..."

status=$(kapp inspect -a cert-manager.app --status --json | jq '.Lines[1]' -)
if [[ '"Succeeded"' == ${status} ]]; then
    echo -e "✅ The package has been installed successfully.\n"
    exit 0
else
    echo -e "🚫 Something wrong happened during the installation of the package.\n"
    exit 1
fi
