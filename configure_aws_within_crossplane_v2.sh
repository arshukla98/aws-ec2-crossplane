#!/bin/bash

# Create Crossplane Provider
cat <<EOF | sudo microk8s kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: crossplane-provider-aws-3
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.41.0
EOF

echo "Crossplane AWS Provider created."

# Wait for the Crossplane Provider to be installed
sudo microk8s kubectl wait "providers.pkg.crossplane.io/crossplane-provider-aws-3" --for=condition=Installed --timeout=1000s
sudo microk8s kubectl wait "providers.pkg.crossplane.io/crossplane-provider-aws-3" --for=condition=Healthy --timeout=1000s

# Get the Crossplane Provider
sudo microk8s kubectl get providers.pkg.crossplane.io

# Create Provider Config
cat <<EOF | sudo microk8s kubectl apply -f -
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: upbound-provider
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
sudo microk8s kubectl wait --timeout=10m providerconfig.aws.upbound.io/upbound-provider

# Get the ProviderConfigs
sudo microk8s kubectl get providerconfig.aws.upbound.io
