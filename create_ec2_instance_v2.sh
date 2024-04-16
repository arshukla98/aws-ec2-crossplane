#!/bin/bash

generate_aws_keyPair_yaml() {
cat <<EOF
apiVersion: ec2.aws.upbound.io/v1beta1
kind: KeyPair
metadata:
  name: $keyName
spec:
  providerConfigRef:
    name: upbound-provider
  forProvider:
    region: $region
    publicKey: $publicKey
    tags:
        Name: $keyName
EOF
}

# Function to generate EC2 YAML content
generate_ec2_yaml() {
cat <<EOF
apiVersion: ec2.aws.upbound.io/v1beta1
kind: Instance
metadata:
  name: $resourceName
spec:
  forProvider:
    region: $region
    ami: $imageID
    instanceType: $instanceType
    keyName: $keyName
    tags:
        Name: "$vmName"
  providerConfigRef:
    name: upbound-provider
EOF
}

# Check if all required arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <imageID> <instanceType> <region> <publicKey> <vmName>"
    exit 1
fi

# Assign command-line arguments to variables
imageID=$1
instanceType=$2
region=$3
publicKey=$4
vmName=$5

keyname="backstage-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"
resourceName="backstage-ec2-$(cat /proc/sys/kernel/random/uuid | cut -d '-' -f1)"

# Call function to generate EC2 YAML
generate_aws_keyPair_yaml > ec2-instance-keyPair.yaml

# Call function to generate EC2 YAML
generate_ec2_yaml > ec2-instance.yaml

echo "YAML files has been generated."

sudo microk8s kubectl create -f ec2-instance-keyPair.yaml

sudo microk8s kubectl wait --timeout=5m --for=condition=Ready instance.ec2.aws.upbound.io/$keyName

sudo microk8s kubectl get keypairs.ec2.aws.upbound.io -A

sleep 20

sudo microk8s kubectl create -f ec2-instance.yaml

# Wait for the EC2 Instance to be ready
sudo microk8s kubectl wait --timeout=5m --for=condition=Ready instance.ec2.aws.upbound.io/$resourceName

sudo microk8s kubectl get instances.ec2.aws.upbound.io -A
