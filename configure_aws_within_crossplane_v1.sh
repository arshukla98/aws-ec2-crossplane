#!/bin/bash

# Create Crossplane Provider
cat <<EOF | sudo microk8s kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: crossplane-provider-aws-1
spec:
  package: crossplane-contrib/provider-aws:v0.47.1
EOF

echo "Crossplane Provider created."

# Wait for the Crossplane Provider to be installed
sudo microk8s kubectl wait --timeout=2m --for=condition=Healthy provider.pkg.crossplane.io/crossplane-provider-aws-1

# Get the Crossplane Provider
sudo microk8s kubectl get provider.pkg.crossplane.io

# Create Provider Config
cat <<EOF | sudo microk8s kubectl apply -f -
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: crossplane-provider-config
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-secret
      key: creds
EOF

echo "Provider Config created."

# Wait for the Provider Config to be created
sudo microk8s kubectl wait --timeout=2m providerconfig.aws.crossplane.io/crossplane-provider-config

# Get the ProviderConfigs
sudo microk8s kubectl get providerconfig.aws.crossplane.io
