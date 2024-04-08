#!/bin/bash

# Function to generate YAML content
generate_yaml() {
cat <<EOF
apiVersion: ec2.aws.crossplane.io/v1alpha1
kind: Instance
metadata:
  name: $resourceName
spec:
  forProvider:
    region: $region
    imageId: $imageID
    instanceType: $instanceType
    keyName: $keyName
    tags:
      - key: Name
        value: "$vmName"
  providerConfigRef:
    name: crossplane-provider
EOF
}

# Check if all required arguments are provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <imageID> <instanceType> <region> <keyName> <vmName> <resourceName>"
    exit 1
fi

# Assign command-line arguments to variables
imageID=$1
instanceType=$2
region=$3
keyName=$4
vmName=$5
resourceName=$6

# Call function to generate YAML
generate_yaml > ec2-instance.yaml

echo "YAML file ec2-instance.yaml has been generated."

sudo microk8s kubectl create -f ec2-instance.yaml

# Wait for the EC2 Instance to be ready
sudo microk8s kubectl wait --timeout=5m --for=condition=Synced instance.ec2.aws.crossplane.io/$resourceName

sudo microk8s kubectl get instances.ec2.aws.crossplane.io -A
